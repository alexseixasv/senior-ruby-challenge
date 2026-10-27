module QueryCounter
  module_function

  def capture
    queries = []
    callback = lambda do |_name, _started, _finished, _id, payload|
      sql = payload[:sql].to_s
      next if payload[:cached]
      next if payload[:name] == "SCHEMA"
      next if sql.match?(/\A\s*(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE|SET\b)/i)

      queries << sql
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    queries
  end
end
