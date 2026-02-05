# SageMaker Distribution Upgrade: Decisions & Rationale

## Overview
Upgraded the amazon-sagemaker-build-train-deploy workshop from SageMaker Distribution 1.11 to 3.6.2 for use in SageMaker Studio.

## Key Decisions

### 1. Image Selection: SageMaker Distribution 3.6.2
**Decision:** Use `SAGEMAKER_INTERNAL_IMAGE_URI` environment variable to get the exact container image.

**Why:** 
- The `@remote` decorator needs the same image as JupyterLab to avoid Python/library version mismatches
- Public ECR (`public.ecr.aws/sagemaker/sagemaker-distribution`) doesn't work in VPC-only mode
- Private ECR (`542918446943.dkr.ecr...`) requires cross-account permissions we couldn't configure
- `SAGEMAKER_INTERNAL_IMAGE_URI` provides the exact image URI with SHA digest that SageMaker already has access to

**Code:**
```python
import os
sm_dist_image = os.environ.get('SAGEMAKER_INTERNAL_IMAGE_URI')
```

### 2. Empty requirements.txt
**Decision:** Remove all version-pinned dependencies from requirements.txt.

**Why:**
- The original `requirements.txt` pinned `scikit-learn==1.3.2` and `sagemaker==2.219.0`
- These downgrades caused `libstdc++.so.6: version CXXABI_1.3.15 not found` errors
- SageMaker Distribution 3.6.2 already includes all needed packages at compatible versions
- Installing older versions breaks binary compatibility with the container's system libraries

**Before (broken):**
```
sagemaker==2.219.0
scikit-learn==1.3.2
mlflow==2.17.0
```

**After (working):**
```
# No additional packages needed - SageMaker Distribution 3.6.2 includes all required dependencies
```

### 3. OneHotEncoder sparse_output Parameter
**Decision:** Add `sparse_output=False` to OneHotEncoder.

**Why:**
- scikit-learn 1.2+ renamed `sparse` parameter to `sparse_output`
- Models pickled with old parameter names fail to deserialize
- Explicit parameter avoids version-dependent behavior

**Code:**
```python
OneHotEncoder(sparse_output=False)
```

### 4. IAM Permissions for ECR
**Decision:** Added ECR cross-account pull permissions to the SageMaker execution role.

**Why:**
- VPC-only domains need explicit ECR permissions even for AWS-managed images
- Added to CloudFormation templates for reproducibility

**Permissions added:**
```yaml
- ecr:BatchCheckLayerAvailability
- ecr:BatchGetImage
- ecr:GetDownloadUrlForLayer
- ecr:GetAuthorizationToken
```

### 5. Fresh JupyterLab App Required
**Decision:** Delete and recreate JupyterLab app after pip pollution.

**Why:**
- Running `%pip install -r requirements.txt` with old pinned versions permanently modified the environment
- Kernel restart doesn't restore packages - they're installed to disk
- Only way to get clean environment is to recreate the app

## Version Compatibility Matrix

| Component | Version | Notes |
|-----------|---------|-------|
| SageMaker Distribution | 3.6.2 | Python 3.12 |
| Python | 3.12.9 | All 3.x distributions use 3.12 |
| scikit-learn | 1.7.2 | Container default, don't downgrade |
| sagemaker SDK | 2.245.0 | Container default |
| mlflow | 2.22.0 | Container default |

## Files Modified

1. `01_build_and_train/01_build_and_train.ipynb` - Image URI, OneHotEncoder fix
2. `01_build_and_train/requirements.txt` - Emptied
3. `setup/vpc_mode/02_sagemaker_studio.yaml` - ECR permissions
4. `setup/direct_mode/02_sagemaker_studio.yaml` - ECR permissions
5. Multiple files - Version references updated from 1.11 → 3.6.2
6. Multiple files - GitHub URLs updated to fork

## Lessons Learned

1. **Never pin package versions lower than container defaults** - causes binary incompatibilities
2. **Use `SAGEMAKER_INTERNAL_IMAGE_URI`** for @remote decorator in Studio
3. **VPC-only mode requires explicit ECR permissions** even for AWS images
4. **pip install pollution requires app recreation** - kernel restart insufficient
5. **SageMaker Distribution 3.x = Python 3.12** - no 3.x version has Python 3.11
