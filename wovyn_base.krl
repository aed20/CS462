ruleset wovyn_base {
  meta {
    use module io.picolabs.twilio_keys
    use module io.picolabs.twilio alias twilio
      with account_sid = keys:twilio{"account_sid"}
           auth_token = keys:twilio{"auth_token"}
  }
  global {
    temperature_threshold = 78.00
    sms_num = 16196546028
    twilio_num = 16072694036
  }

  rule process_heartbeat {
    select when wovyn heartbeat
    pre{
      is_null = event:attr("genericThing").isnull()
      temp = event:attr("genericThing").get(["data","temperature"]).head().get(["temperatureF"]).klog("temperature")
    }
    if not is_null then noop()
    fired{
      raise wovyn event "new_temperature_reading" attributes {
        "temperature": temp,
        "timestamp": time:now()
      }
    }
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre{
      message = event:attr("temperature") > temperature_threshold => "TEMPERATURE VIOLATION!" | "No temp violation"
      violation = event:attr("temperature") > temperature_threshold
    }
    send_directive("response", {"something": message})
    fired{
      raise wovyn event "threshold_violation" attributes{
        "temperature": event:attr("temperature"),
        "timestamp": event:attr("timestamp")
      } if violation
    }
  }

  rule threshold_notification{
    select when wovyn threshold_violation
    twilio:send_sms(sms_num,
                    twilio_num,
                    "The temperature is too high!"
                   )
  }
}
