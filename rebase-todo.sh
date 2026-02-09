#!/bin/bash
cat > "$1" << 'EOF'
# Group 1: SageMaker upgrade
pick 39e74c0 Add Mlflow, local mode, and project prefix (#35)
squash 3d7dee4 Upgrade SageMaker Distribution from 1.11 to 2.13
squash be5f252 Update SageMaker Distribution to 3.6.2

# Group 2: Container fixes
pick 294f79a Add config.yaml to fix @remote decorator image mismatch
squash b7c4c92 Add ImageUri to notebook config to fix scipy/libstdc++ mismatch
squash abd4dbe Use private ECR image for VPC-only mode
squash e2d4440 Dynamically generate ECR image URI from SSM parameter
squash 65db7a0 Use describe_image_version to get exact matching container image
squash fd94dfb Get image URI from space metadata to avoid permission issues
squash 6870a54 Add ECR cross-account pull permissions for SageMaker Distribution images
squash d6a3118 Use public ECR gallery image to avoid cross-account permission issues
squash 3f5e3c5 Use SageMaker managed PyTorch image for VPC mode compatibility
squash 5a8c8e1 Try to get exact ECR image URI from JupyterLab container
squash c726184 Use SAGEMAKER_INTERNAL_IMAGE_URI for exact image match

# Group 3: Dependencies
pick 6578194 Remove version pins causing scikit-learn downgrade and libstdc++ incompatibility
squash d12a44c Empty requirements.txt - container already has all needed packages
squash 6e166b9 Fix 02_deploy requirements to avoid version conflicts with SM Distribution 3.6.2
squash c8ff984 Pin protobuf<4.0 to fix sklearn container compatibility
squash f2ea7af Disable ModelBuilder auto-detection and fix requirements in modules 2 and 3
squash aa3ce6e Revert auto:False - ModelBuilder requires sagemaker SDK for generated inference.py
squash 500fc04 Update mlflow version

# Group 4: Code compatibility
pick 43b5354 Fix OneHotEncoder sparse_output for scikit-learn 1.2+ compatibility
squash cf8ef67 Add cache bust parameter to force fresh remote execution
squash 759dad2 Remove unnecessary TorchServe model server to avoid CUDA downloads

# Group 5: Documentation
pick 80fce75 Update README
squash 9155084 Update the workshop name
squash 2ab857b Add upgrade decisions documentation
squash d4df720 Update repo URLs to use lukewma-aws fork
EOF