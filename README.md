# CodePipeline Template

This repo is a template for containerized applications deployed with CodePipeline -> CodeBuild -> CloudFormation -> ECS

### GitHub Authentication Setup

1. Create a Personal Access Token in GitHub for CodePipeline: https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-create-personal-token-CLI.html
2. Place the Personal Access Token in an SSM Parameter in the desired AWS Account / Region named `/CodePipeline/GitHub`

### Application Deployment

1. Authenticate to desired AWS Account with Administrator Access in your bash shell
2. Navigate to root directory of this repository
3. Review parameters in `config.sh` and update (if needed)
4. Run `./init <Branch Name>` ("Branch Name" must exist in the repository)
5. Watch CloudFormation console for progress deploying initializer template (`build/init.yml`)
6. Watch CodePipeline console for progress of first pipeline run & monitor CodeBuild + CloudFormation progress
7. Commit + Push changes to branch in order to trigger a new build

### Notes

* CodeBuild + CodePipeline + CloudFormation IAM Roles are currently overprivileged and should be scoped better 
* Load Balancer should be configured to make a better HA ECS deployment
* Web Stack is currently disabled (commented out) but will enable CloudFront + API Gateway + Lambda (talk to Marty first if you want to explore)
* Load Balancer could be added as an origin behind CloudFront + Route53 Config
