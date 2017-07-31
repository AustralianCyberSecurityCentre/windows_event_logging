# ACSC's Windows Event Logging repository #

This repository contains Windows Event Forwarding subscriptions, configuration files and scripts that are referenced by ACSC's protect publication, [Technical Guidance for Windows Event Logging](https://asd.gov.au/publications/protect/windows-event-logging-technical-guidance.htm).

The repository is structured by having a matching folder per event category from the publication. This contains the subscriptions and as required other configuration files or scripts.

### Subscriptions ###

Subscriptions are added to the log collection server and determine which events are forwarded. They are named with a consistent suffix, _sub.xml, to make it easier to programmatically add subscriptions.

Subscriptions in this repository are created with the following configuration:

* they are designed to forward valuable telemetry but reduce noise if possible
* since wildcards are not supported by subscriptions, some paths need to be hard-coded - this should be modified for environments that do not use standard paths
* set to be enabled by default unless the event log may not always exist or if it has the potential to bring back large volumes of data
* set to use the content format of Events as opposed to RenderedText which reduces the volume of data being transferred
* set to read existing events as opposed to only new events
* set that the output goes to the ForwardedEvents log 

### Helper Scripts ###

There are two small PowerShell scripts that simplify the process of adding subscriptions:

* *events/add_subscriptions.ps1* - Adds all subscriptions. For each event category folder, it adds subscription files based on the _sub.xml naming.
* *events/set_subscriptions_sources.ps1* - Sets all subscriptions to have the source computer groups of Domain Computers and Domain Controllers by default, or if the command line argument -SourceSDDL is specified then a custom [Security Descriptor Definition Language](https://msdn.microsoft.com/en-us/library/windows/desktop/aa379567.aspx) (SDDL).

### Sysmon ###

[Sysmon](https://technet.microsoft.com/en-us/sysinternals/bb545021.aspx) provides greater visibility of system activity than standard Windows logging. The configuration file, subscriptions and an example MSI are included in *events/sysmon*.

The Sysmon configuration, *events/sysmon/sysmon_config.xml* should suit many different environments but may need to be tweaked in some cases. The file contains comments and links that may help in doing this.

There are instructions contained within *events/sysmon/msi/README.txt* on how to build a Sysmon MSI, which may simplify the deployment of Sysmon. The resulting MSI should be tested before a domain-wide rollout.

### WMI ###

Windows Management Instrumentation (WMI) requires additional configuration, which is enabled by running the PowerShell script *events/wmi_auditing/wmi_auditing.ps1*. This script sets auditing records (SACLs) on sensitive WMI nodes, and when these nodes are accessed and the *Audit Other Object Access* option is enabled, WMI auditing logs are produced.

### Copyright and License ###

© Commonwealth of Australia 2017

See [License](LICENSE).
