module Sidetiq
  class Schedule < IceCube::Schedule
    def method_missing(meth, *args, &block)
      if IceCube::Rule.respond_to?(meth)
        rule = IceCube::Rule.send(meth, *args, &block)
        add_recurrence_rule(rule)
        rule
      else
        super
      end
    end

    def schedule_next?(time)
      if @last_scheduled != (no = next_occurrence(time))
        @last_scheduled = no
        return true
      end
      false
    end
  end
end

