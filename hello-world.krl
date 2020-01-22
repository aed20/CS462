ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Phil Windley"
    logging on
    shares hello
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule hello_world {
    select when echo hello
    send_directive("say", {"something": "Hello World"})
  }

  rule hello_monkey_defaults {
  select when echo monkey
  send_directive("say", {"something": "Hello " + event:attr("name").defaultsTo("Monkey").klog("var")})
}

rule hello_monkey_ternary {
  select when echo monkey
  pre{
    x = event:attr("name").isnull() =>
                                      "Monkey" |
                                      event:attr("name");
  }
  send_directive("say", {"something": "Hello " + x})
}

}
