```sh
# Instead of go over each module in each environment. We will run all using terragrunt run-all command
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply --terragrunt-non-interactive # echo "Y" | terragrunt apply-all
terragrunt run-all destroy --terragrunt-non-interactive
# During provision all infrastructure. If some modules corrupt then you could get into specific module folder to recreate it manually
```
https://aztfmod.github.io/documentation/docs/fundamentals/lz-intro