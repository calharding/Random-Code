#!/usr/bin/python
import os
import subprocess
import smtplib
import time

from email.mime.text import MIMEText

#### START OF USER CONFIGURATION ####

sipNumLines = 10   # how many lines do we expect to be registered?
retryDelay = 10 # how many seconds should we wait before retrying? (in the event of other faults)

mailFrom = 'user1@test.com'
mailTo = 'user2@test.com'
mailSubj = 'Asterisk sip registration status'

statusFile = '/root/.asterStatus'

asteriskExe = '/usr/sbin/asterisk'

#### END OF USER CONFIGURATION ####


##################################################################
#########          DO NOT MODIFY ANYTHING BELOW         ##########
##################################################################



def sendEmail(mailFrom, mailTo, mailSubj, mailBody):
    msg = MIMEText(mailBody)

    msg['Subject'] = mailSubj
    msg['From'] = mailFrom
    msg['To'] = mailTo

    # Send the mail using our own SMTP server, but do not include the
    # envelope header.
    s = smtplib.SMTP('localhost')
    s.sendmail(mailFrom, mailTo, msg.as_string())
    s.quit()



def checkLastStatus():
    with open(statusFile) as f:
        content = f.readlines()
        status,count = content[0].split(',')

    return [status, int(count)]



def checkSIPStatus(testnum=1):
    registrationOK=True
    global errormsg
    errormsg = ""

    SIPstatus = os.popen(asteriskExe + " -x 'sip show registry'").read().split('\n')

    if len(SIPstatus) < (sipNumLines+3):       # output incorrect
        registrationOK = False
        errormsg = "Not enough SIP lines detected. Expecting " + str(sipNumLines) + "\n"
        for line in SIPstatus:
            errormsg = errormsg + line + "\n"
    else:
        for line in SIPstatus:
            words = line.split()
            if (len(words) > 4) and (words[2] != "Username"):
                print words[2]+" "+words[4]
                if words[4] != "Registered":
                    # SIP line NOT registered.
                    print words[2]+" is not registered. state="+words[4]
                    registrationOK=False
                    errormsg=errormsg + line + "\n"


    if registrationOK == False:
        if testnum < 2:
            print "waiting... (" + str(testnum) + ")"
            time.sleep(retryDelay)
            registrationOK = checkSIPStatus(testnum+1)

    return registrationOK



# check SIP status
registrationOK=True
errormsg=""

registrationOK = checkSIPStatus()
lastStatus = checkLastStatus()
failCount = 0

if registrationOK == False:     # Problems!
    print "SIP registration errors!"

    if lastStatus[0] == 'OK':
        failCount = 1
    else:
        failCount = lastStatus[1] + 1

        print 'repeated failure ('+str(failCount)+')'

    if failCount == 1:
        print 'sending failure notification'
        print "trying 'module reload'"
        print os.popen(asteriskExe + " -x 'module reload'").read()
        sendEmail(mailFrom,mailTo,mailSubj+': registration failed',errormsg + '\n\n sending command "module reload"')
    elif failCount == 2:
        print "trying 'core restart gracefully'"
        print os.popen(asteriskExe + " -x 'core restart gracefully'").read()
        sendEmail(mailFrom,mailTo,mailSubj+': registration failed ('+str(failCount)+')',errormsg + '\n\n sending command "core restart gracefully"')
    elif failCount == 10:
        sendEmail(mailFrom,mailTo,mailSubj+": registration failed ("+str(failCount)+")",errormsg)
    elif failCount == 30:
        sendEmail(mailFrom,mailTo,mailSubj+": registration failed ("+str(failCount)+")",errormsg)
    elif failCount == 60:
        sendEmail(mailFrom,mailTo,mailSubj+": registration failed ("+str(failCount)+")",errormsg)
    elif failCount == 120:
        sendEmail(mailFrom,mailTo,mailSubj+": registration failed ("+str(failCount)+")",errormsg)
    elif failCount == 240:
        sendEmail(mailFrom,mailTo,mailSubj+": registration failed ("+str(failCount)+")",errormsg)


else:
    print "SIP registration is fine. Everything seems healthy."

    if lastStatus[0] == 'FAIL':
        print 'sending restore notification'
        sendEmail(mailFrom,mailTo,mailSubj+': OK','SIP registration is fine again')

    failCount = 0



# save status
f = open(statusFile,'w')
if registrationOK == True:
    f.write("OK,"+str(failCount))
else:
    f.write("FAIL,"+str(failCount))
f.close()
