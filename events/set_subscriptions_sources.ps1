# Set source computer groups for all Windows Event logging subscriptions

param(
# This SDDL maps to the Domain Controllers and Domain Computers groups and should be universial on domain connected computers.
# The -SourceSDDL argument can be specified with an alternative SDDL if desired.
[string]$SourceSDDL="O:NSG:BAD:P(A;;GA;;;DC)(A;;GA;;;DD)S:"
)
wecutil.exe es | Foreach { wecutil.exe ss $_ /adc:$SourceSDDL }
