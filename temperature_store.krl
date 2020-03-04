ruleset temperature_store {
  meta {
    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures, __testing
  }
  global {
     __testing = {
    "queries":[{"name":"inrange_temperatures"},{"name":"temperatures"},{"name":"threshold_violations"}]
  }
    temperatures = function(){
      return ent:temps
    }
    threshold_violations = function(){
      return ent:violations
    }
    inrange_temperatures = function(){
      //return all temperatures that are not violations
      return ent:temps.difference(ent:violations)
    }

  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temp = event:attr("temperature").klog("passed-in temp: ")
      timestamp = event:attr("timestamp").klog("time: ")
    }
    fired {
      //may contain regular and violation temperatures
      ent:temps := ent:temps.defaultsTo([]).append({"time":event:attr("timestamp"), "temp":event:attr("temperature")})
    }
  }

  rule collect_threshold_violations {
    select when wovyn threshold_violation
    pre{
      temp = event:attr("temperature").klog("temp")
      timestamp = event:attr("timestamp").klog("time")
    }
    fired {
      ent:violations := ent:violations.defaultsTo([]).append({"time":event:attr("timestamp"), "temp":event:attr("temperature")})

    }
  }

  rule clear_temperatures {
    select when sensor reading_reset
    pre {
      temps = ent:temps.klog("before clearing temps")
      vios = ent:violations.klog("before clearing violations")
    }
    fired {
      clear ent:temps
      clear ent:violations
      temps = ent:temps.klog("cleared temps:")
      vios = ent:violations.klog("cleared violations:")

    }
  }
}
