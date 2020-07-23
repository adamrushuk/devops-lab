# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # 'Az' = '4.*'
    # Only need compute cmdlets for VMSS and VM status checks
    'Az.Compute' = '4.*'
}
