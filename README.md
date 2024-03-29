# Azure Kubernetes Service (AKS) baseline cluster

### Current implementation

![Basic secure Cloud-Native Architecture using Kubernetes on Azure.](docs/basic-secure-aks.png)

Ref: https://youtu.be/fRU3-TbXiwg


## The future implementation
### Core architecture components

#### Azure platform

- AKS v1.25
  - System and User [node pool separation](https://learn.microsoft.com/azure/aks/use-system-pools)
  - [AKS-managed Azure AD](https://learn.microsoft.com/azure/aks/managed-aad)
  - Azure AD-backed Kubernetes RBAC (_local user accounts disabled_)
  - Managed Identities
  - Azure CNI
  - [Azure Monitor for containers](https://learn.microsoft.com/azure/azure-monitor/insights/container-insights-overview)
- Azure Virtual Networks (hub-spoke)
  - Azure Firewall managed egress
- Azure Application Gateway (WAF)
- AKS-managed Internal Load Balancers

#### In-cluster OSS components

- [Azure Workload Identity](https://learn.microsoft.com/azure/aks/workload-identity-overview) _[AKS-managed add-on]_


![Network diagram depicting a hub-spoke network with two peered VNets and main Azure resources used in the architecture.](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/images/secure-baseline-architecture.svg)


https://learn.microsoft.com/en-us/users/nityan/collections/xz6ehr3z7o7e1q?fbclid=IwAR38BkAaSR537OExyllDiVIF-BaZyHmIQ711RW2qVn9Ea0gZ1XRk0ozwzYg

## Extras
https://techcommunity.microsoft.com/t5/fasttrack-for-azure/deploy-and-run-a-azure-openai-chatgpt-app-on-aks-with-terraform/ba-p/3839611