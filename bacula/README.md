# Info

These project was tested with Bacula Director 7.0.5 from Ubuntu 16.04 official repositories.
Python is a pre-requisite.

For this, I considered that the jobs are executed only once a day.
If you schedule your jobs to be executed twice, the discovery rules will make them appear twice.

# Introduction

This project includes several scripts that must be executed as cron jobs.
This is because Bacula Console (`bconsole`) is executed with root privileges. Even if we try to run `bconsole` as
the `zabbix` user, we must grant read access do `bconsole.conf` configuration file, which includes the plain-text
password for communication with Bacula Director.

So, there are three scripts that are executed from Cron jobs. They run as `root` user and save the data in text files that
can be read by `zabbix`.
The scripts are listed below with their respective functions:

* `bacula_numjobs.sh` - Returns the number of jobs scheduled for **today**;
* `bacula_status_scheduled.sh` - Returns the status of **Incremental** and **Full** jobs scheduled for **today**. This one
just calls `status scheduled days=1` from `bconsole` and filters the output. Note that `status scheduled` was introduced with
Bacula 7.0;
* `bacula_list_jobs.sh` - Just runs `list jobs` in `bconsole`.

# Installation

## Scripts

Choose a directory to put the scripts in and a directory to save the data to be read by `zabbix` user.
Here, I chose `/usr/share/zabbix-agent` for both.
Download the contents of `scripts` folder to the chosen directory.

The, create the Cron jobs accordingly:

```bash
$ sudo crontab -e -u root
```
Insert the following in your file, adjusting the directories as needed:

```cron
* * * * * /usr/share/zabbix-agent/bacula_numjobs.sh > /usr/share/zabbix-agent/bacula_numjobs
* * * * * /usr/share/zabbix-agent/bacula_status_scheduled.sh > /usr/share/zabbix-agent/bacula_status_scheduled
* * * * * /usr/share/zabbix-agent/bacula_list_jobs.sh > /usr/share/zabbix-agent/bacula_list_jobs
```

This will run the three scrips every minute.

Create the Agent configuration file for Bacula. 
Here, i'm assuming that the main configuration file (`zabbix_agentd.conf`) includes the `conf` files that are inside
`zabbix_agentd.d` (also given as exemple).
So we put the `bacula.conf` file inside `/etc/zabbix/zabbix_agentd.d/` and then restart the Zabbix Agent service:

```
$ sudo systemctl restart zabbix-agent.service
```

## Zabbix Interface

Now, we just need to add the items do the appropriate host on Zabbix.

Go to `Configuration -> Hosts`, select the host and select `Discovery Rules`.
Create a new discovery rule (you name it, I used *Bacula Job Discovery*) with the fields:

* Name: `Bacula Job Discovery`
* Type: Zabbix agent
* Key: `bacula.jobdiscovery`
* Update Interval: 60 seconds **minimum**

Now, for this Discovery Rule, create the Item Prototypes:

### Item Prototypes

#### Job Bytes
* Name: `Job Bytes of Job $1`
* Type: Zabbix agent
* key: `bacula.jobbytes[{#JOBNAME}]`
* Type of information: Numeric (float)
* (Optional) Name `New Application Prototype` with something useful (I used *Bacula*)

#### Job Files
* Name: `Job Files of Job $1`
* Type: Zabbix agent
* key: `bacula.jobfiles[{#JOBNAME}]`
* Type of information: Numeric (float)
* (Optional) Select Application Prototype if you named that in the previous item.

#### Job Status
* Name: `Job Status of Job $1`
* Type: Zabbix agent
* key: `bacula.jobstatus[{#JOBNAME}]`
* Type of information: Numeric (unsigned) or Character
* (Optional) Select Application Prototype if you named that in the previous item.

### Trigger Prototypes

#### Error
* Name: `Bacula Job {#JOBNAME} Error`
* Expression: `{bacula-director:bacula.jobstatus[{#JOBNAME}].last(#1)}=5` (note that you must replace `bacula-director` with
your host. Use the Expression Constructor to favor).
* Description: You name it!
* Severity; You name it! (I used `High`)

#### Failed

* Name: `Bacula Job {#JOBNAME} Failed`
* Expression: `{bacula-director:bacula.jobstatus[{#JOBNAME}].last(#1)}=1` (note that you must replace `bacula-director` with
your host. Use the Expression Constructor to favor).
* Description: You name it!
* Severity; You name it! (I used `High`)

### Value Mappings

The UserParamater maps the Bacula status code (`f,t,R,C,E`) to an integer (you can see this mapping in `bacula.conf`).
So, for `f` (fail) we have the number `1` and for `E` (error) we have the
number `5`.

So it is nice to create the Value Mappings accordingly.
Go to `Administration -> General` and on the top right drop-down, select `Value Mapping`.
Create a new one:

* Name: `Bacula Job Status`
* Value: `1` Mapped To `failed`
* Value: `2` Mapped To `Terminated`
* Value: `3` Mapped To `Running`
* Value: `4` Mapped To `Cancelled`
* Value: `5` Mapped To `Error`

Go back to the Item Prototype `Job Status of Job $1` you created previously and change de `Show Value` field to the Value
mapping you created above (`Bacula Job Status`).

That's it!
