# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    'Az' = '5.*'
    # Only need Account and Compute cmdlets for VMSS and VM status checks
    # 'Az.Accounts' = '2.*'
    # 'Az.Compute' = '4.*'
}
