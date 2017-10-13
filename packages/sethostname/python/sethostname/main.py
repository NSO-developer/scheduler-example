# -*- mode: python; python-indent: 4 -*-
import ncs
from ncs.application import Service

#import for the scheduler
import _ncs
from datetime import datetime


class ServiceCallbacks(Service):

    # The create() callback is invoked inside NCS FASTMAP and
    # must always exist.
    @Service.create
    def cb_create(self, tctx, root, service, proplist):
        self.log.info('Service create(service=', service._path, ')')

        vars = ncs.template.Variables()

        ###############################################
        #Scheduler code below
        ###############################################
        vars.add('SERVICEACTIVE', '')
        now = datetime.now()

        #get the service xpath
        trans = service._backend.trans
        trans.cd(service._path)
        service_xpath = str(_ncs.xpath_pp_kpath(trans.getcwd_kpath()))
        print('xpath: ' + service_xpath)
        vars.add('SERVICEXPATH', service_xpath)

        if service.schedule.run_at:
            activation_time = datetime.strptime(service.schedule.run_at, '%Y-%m-%dT%H:%M:%S')
            #Check if activation time is passed
            #why < and not >, no idea :(
            if activation_time < now:
                print('Service active now: ' + str(now) + ' activation time: ' + str(activation_time))
                vars.add('SERVICEACTIVE','TRUE')
                service.schedule.activation_time = str(now)
            else:
                print('Service not active now: ' + str(now) + ' activation time: ' + str(activation_time))
                if service.schedule.activation_time:
                    del(service.schedule.activation_time)

            #always create the scheduler
            time = service.schedule.run_at.split('T')[1]
            date = service.schedule.run_at.split('T')[0]
            vars.add('MONTH', date.split('-')[1])
            vars.add('DAY', date.split('-')[2])
            vars.add('HOUR', time.split(':')[0])
            vars.add('MINUTE', time.split(':')[1])

        else:
            #if no run_at time exists, the service should be active
            vars.add('SERVICEACTIVE','TRUE')
            print('Service active - no schedule')
            vars.add('MONTH', '')
            vars.add('DAY', '')
            vars.add('HOUR', '')
            vars.add('MINUTE', '')
            service.schedule.activation_time = str(now)
        ##############################################

        template = ncs.template.Template(service)
        template.apply('sethostname-template', vars)




# ---------------------------------------------
# COMPONENT THREAD THAT WILL BE STARTED BY NCS.
# ---------------------------------------------
class Main(ncs.application.Application):
    def setup(self):
        # The application class sets up logging for us. It is accessible
        # through 'self.log' and is a ncs.log.Log instance.
        self.log.info('Main RUNNING')

        # Service callbacks require a registration for a 'service point',
        # as specified in the corresponding data model.
        #
        self.register_service('sethostname-servicepoint', ServiceCallbacks)

        # If we registered any callback(s) above, the Application class
        # took care of creating a daemon (related to the service/action point).

        # When this setup method is finished, all registrations are
        # considered done and the application is 'started'.

    def teardown(self):
        # When the application is finished (which would happen if NCS went
        # down, packages were reloaded or some error occurred) this teardown
        # method will be called.

        self.log.info('Main FINISHED')
