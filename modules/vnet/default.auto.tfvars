application             = "vnetflix"
azure_location          = "eastus2"
aks_spoke_address_space = ["10.0.0.0/16"]
# aks_spoke_subnets=[
#     {
#         name="workloads"
#         address_prefixes=["10.0.1.0/24"]
#     },
#     {
#         name="web-application-gateway"
#         address_prefixes=["10.0.2.0/24"]
#     },
#     {
#         name="private-link-endpoints"
#         address_prefixes=["10.0.3.0/24"]
#     },
#     {
#         name="internal-load-balancers"
#         address_prefixes=["10.0.4.0/24"]
#     }
# ]
aks_spoke_subnets = {
  workloads = {
    address_prefixes = ["10.0.1.0/24"]
  },
  web-application-gateway = {
    address_prefixes = ["10.0.2.0/24"]
  },
  private-link-endpoints = {
    address_prefixes = ["10.0.3.0/24"]
  },
  internal-load-balancers = {
    address_prefixes = ["10.0.4.0/24"]
  }
}