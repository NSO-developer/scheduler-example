# scheduler-example
A quick hack to add a scheduler to your service, it kind misuses the new scheduler that was added to NSO 4.5. Its more of a hack than something for production use as it has a "few" shortcomings like doesnt actually care about years or seconds, doesnt remove the scheduler after it fired etc.

Its a full runtime folder.


```
11:53 $ make all start
ncs-netsim start
DEVICE c0 OK STARTED
ncs

11:54 $ make cli
ncs_cli -u admin

admin connected from 127.0.0.1 using console on HNISKA-M-D399
admin@ncs> configure
Entering configuration mode private
[ok][2017-10-13 11:54:11]

[edit]
admin@ncs% show scheduler
No entries found.
[ok][2017-10-13 11:54:16]

[edit]
admin@ncs% request devices sync-from
sync-result {
    device c0
    result true
}
[ok][2017-10-13 11:54:43]

[edit]
admin@ncs% set sethostname c0-hostname device c0 schedule
Possible completions:
  run-at         - format: YYYY-MM-DDTHH:MM:SS
  service-active -
admin@ncs% set sethostname c0-hostname device c0 schedule run-at 2017-10-13T11:58:00
[ok][2017-10-13 11:56:39]

[edit]
admin@ncs% commit
Commit complete.
[ok][2017-10-13 11:56:40]

[edit]
admin@ncs% show sethostname
sethostname c0-hostname {
    device c0;
    schedule {
        run-at 2017-10-13T11:58:00;
    }
}
[ok][2017-10-13 11:56:41]

[edit]
admin@ncs% show scheduler
task c0-hostname-2017-10-13T11:58:00 {
    schedule    "58 11 13 10 *";
    action-node /sethostname[name='c0-hostname'];
    action-name re-deploy;
}
[ok][2017-10-13 11:56:42]

[edit]
admin@ncs% request sethostname c0-hostname get-modifications
cli {
    local-node {
        data  scheduler {
              +    task c0-hostname-2017-10-13T11:58:00 {
              +        schedule "58 11 13 10 *";
              +        action-node /sethostname[name='c0-hostname'];
              +        action-name re-deploy;
              +    }
               }

    }
}
[ok][2017-10-13 11:56:56]

[edit]
admin@ncs%
System message at 2017-10-13 11:58:01...
Commit performed by admin via system using ncs-scheduler.
admin@ncs% request sethostname c0-hostname get-modifications
cli {
    local-node {
        data  scheduler {
              +    task c0-hostname-2017-10-13T11:58:00 {
              +        schedule "58 11 13 10 *";
              +        action-node /sethostname[name='c0-hostname'];
              +        action-name re-deploy;
              +    }
               }
               devices {
                   device c0 {
                       config {
              +            ios:hostname c0-hostname;
                       }
                   }
               }

    }
}
[ok][2017-10-13 11:59:02]

[edit]
admin@ncs% run show scheduler
scheduler suspended false
                                 IS
NAME                             RUNNING  WHEN                              DURATION  SUCCEEDED  INFO
-------------------------------------------------------------------------------------------------------
c0-hostname-2017-10-13T11:58:00  false    2017-10-13T09:58:00.804647+00:00  0.62 sec  true       -
[ok][2017-10-13 11:59:11]

[edit]
admin@ncs% run show sethostname schedule
NAME         ACTIVATION TIME
-----------------------------------------
c0-hostname  2017-10-13 11:58:00.827042

[ok][2017-10-13 11:59:18]
```

### Contact

Contact Hakan Niska <hniska@cisco.com> with any suggestions or comments. If you find any bugs please fix them and send me a pull request.
