defmodule EventTimerWeb.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    events = EventTimer.Storage.all_events()
    html = generate_page(events)
    send_html(conn, html)
  end

  post "/events" do
    params = conn.body_params
    name = params["name"]
    date = params["date"]
    desc = params["description"] || ""
    days = params["alert_days"] || 7

    result =
      EventTimer.Storage.create_event(%{
        name: name,
        date: date,
        description: desc,
        alert_days: days
      })

    case result do
      event when is_map(event) ->
        send_json(conn, "{\"success\":true}")

      {:error, reason} ->
        send_json(conn, "{\"success\":false,\"error\":\"" <> reason <> "\"}")

      _ ->
        send_json(conn, "{\"success\":false,\"error\":\"Unknown error\"}")
    end
  end

  put "/events/:id" do
    params = conn.body_params

    result =
      EventTimer.Storage.update_event(id, %{
        name: params["name"],
        date: params["date"],
        description: params["description"] || "",
        alert_days: params["alert_days"] || 7
      })

    case result do
      events when is_list(events) ->
        send_json(conn, "{\"success\":true}")

      {:error, reason} ->
        send_json(conn, "{\"success\":false,\"error\":\"" <> reason <> "\"}")

      _ ->
        send_json(conn, "{\"success\":false,\"error\":\"Update failed\"}")
    end
  end

  delete "/events/:id" do
    EventTimer.Storage.delete_event(id)
    send_json(conn, "{\"success\":true}")
  end

  post "/test-notification" do
    case EventTimer.Storage.all_events() do
      [] ->
        send_json(conn, "{\"success\":false}")

      [ev | _] ->
        EventTimer.Notifier.notify_event(ev, 7)
        send_json(conn, "{\"success\":true}")
    end
  end

  post "/reset-notifications" do
    EventTimer.Storage.clear_notified()
    send_json(conn, "{\"success\":true}")
  end

  post "/auto-start" do
    params = conn.body_params
    enabled = params["enabled"] == true
    result = EventTimer.AutoStart.set(enabled)
    send_json(conn, "{\"success\":#{result}}")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp send_html(conn, html) do
    conn |> put_resp_content_type("text/html") |> send_resp(200, html)
  end

  defp send_json(conn, json) do
    conn |> put_resp_content_type("application/json") |> send_resp(200, json)
  end

  defp generate_page(events) do
    today = Date.utc_today()
    autostart = EventTimer.AutoStart.enabled?()

    header = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <title>Eventos Especiales</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 40px 20px; }
        .container { max-width: 600px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: white; font-size: 28px; font-weight: 700; }
        .settings-btn { background: rgba(255,255,255,0.2); border: none; width: 44px; height: 44px; border-radius: 12px; cursor: pointer; color: white; font-size: 20px; transition: 0.2s; }
        .settings-btn:hover { background: rgba(255,255,255,0.3); }
        .card { background: white; padding: 20px; margin-bottom: 16px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); transition: transform 0.2s; }
        .card:hover { transform: translateY(-2px); }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
        .card-title { font-size: 20px; font-weight: 600; color: #1a1a2e; }
        .card-delete { background: none; border: none; color: #e74c3c; cursor: pointer; font-size: 18px; opacity: 0.6; transition: 0.2s; }
        .card-delete:hover { opacity: 1; }
        .countdown { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 8px 16px; border-radius: 20px; font-weight: 600; font-size: 14px; margin-bottom: 12px; }
        .countdown.urgent { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
        .countdown.past { background: #95a5a6; }
        .card-details { color: #666; font-size: 14px; line-height: 1.6; }
        .card-details span { margin-right: 16px; }
        .btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 14px 24px; border: none; border-radius: 12px; cursor: pointer; font-size: 15px; font-weight: 600; transition: 0.2s; }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4); }
        .btn-sec { background: white; color: #667eea; }
        .empty { text-align: center; color: white; padding: 60px 20px; }
        .empty-icon { font-size: 64px; margin-bottom: 16px; }
        .empty-text { font-size: 18px; opacity: 0.9; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; z-index: 9999; }
        .modal { background: white; padding: 32px; border-radius: 20px; width: 90%; max-width: 400px; animation: slideUp 0.3s ease; }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .modal h2 { color: #1a1a2e; margin-bottom: 24px; font-size: 22px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #666; font-size: 13px; font-weight: 500; margin-bottom: 8px; }
        .form-group input, .form-group textarea { width: 100%; padding: 14px; border: 2px solid #eee; border-radius: 10px; font-size: 15px; transition: 0.2s; font-family: inherit; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #667eea; }
        .modal-actions { display: flex; gap: 12px; margin-top: 24px; }
        .modal-actions .btn { flex: 1; text-align: center; }
        .switch { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding: 16px; background: #f8f9fa; border-radius: 12px; }
        .switch input { display: none; }
        .switch-label { flex: 1; }
        .switch-label h4 { color: #1a1a2e; font-size: 15px; margin-bottom: 4px; }
        .switch-label p { color: #666; font-size: 13px; }
        .toggle { width: 50px; height: 28px; background: #ddd; border-radius: 14px; position: relative; cursor: pointer; transition: 0.2s; }
        .toggle::after { content: ''; position: absolute; width: 22px; height: 22px; background: white; border-radius: 50%; top: 3px; left: 3px; transition: 0.2s; }
        .switch input:checked + .toggle { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .switch input:checked + .toggle::after { left: 25px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Eventos Especiales</h1>
          <button class="settings-btn" onclick="openSettings()">⚙</button>
        </div>
    """

    content =
      if length(events) == 0 do
        """
        <div class="empty">
          <div class="empty-icon">📅</div>
          <div class="empty-text">No hay eventos todavía. ¡Agrega tu primer evento!</div>
          <br>
          <button class="btn" onclick="openModal()">+ Agregar Evento</button>
        </div>
        """
      else
        cards = Enum.map(events, fn event -> build_card(event, today) end)

        """
        #{Enum.join(cards, "")}
        <button class="btn" onclick="openModal()">+ Agregar Evento</button>
        """
      end

    footer = """
      </div>
      #{modal()}
      <script>
        var autostart = #{autostart};
        function openModal() {
          document.getElementById('eid').value = '';
          document.getElementById('ename').value = '';
          document.getElementById('edate').value = '';
          document.getElementById('edesc').value = '';
          document.getElementById('edays').value = '7';
          var m = document.getElementById('modal');
          m.style.display = 'flex';
        }
        function openSettings() {
          var m = document.getElementById('settingsModal');
          m.style.display = 'flex';
        }
        function closeModal(id) { document.getElementById(id).style.display = 'none'; }
        function save() {
          var id = document.getElementById('eid').value;
          var name = document.getElementById('ename').value;
          var date = document.getElementById('edate').value;
          var desc = document.getElementById('edesc').value;
          var days = parseInt(document.getElementById('edays').value) || 7;
          if (!name || !date) return alert('El nombre y la fecha son requeridos');
          var data = {name: name, date: date, description: desc, alert_days: days};
          var method = id ? 'PUT' : 'POST';
          var url = id ? '/events/' + id : '/events';
          fetch(url, {method: method, headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data)})
            .then(function(r) { return r.json(); })
            .then(function(r) { if (r.success) { closeModal('modal'); location.reload(); } });
        }
        function del(id) {
          if (confirm('¿Eliminar este evento?')) {
            fetch('/events/' + id, {method: 'DELETE'})
              .then(function(r) { return r.json(); })
              .then(function(r) { if (r.success) location.reload(); });
          }
        }
        function toggleAutoStart(el) {
          var enabled = el.checked;
          fetch('/auto-start', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({enabled: enabled})})
            .then(function(r) { return r.json(); })
            .then(function(r) { if (!r.success) { el.checked = !enabled; alert('Error al actualizar configuración'); } });
        }
      </script>
    </body>
    </html>
    """

    header <> content <> footer
  end

  defp build_card(event, today) do
    id = event.id || ""
    name = event.name || "Unknown"
    date_str = event.date || "Unknown"
    days = to_string(event.alert_days || 7)
    _desc = event.description || ""

    {countdown_text, countdown_class} =
      case parse_date(date_str) do
        {:ok, event_date} ->
          diff = Date.diff(event_date, today)

          cond do
            diff < 0 -> {"Evento pasado", "past"}
            diff <= 3 -> {"#{diff} días restantes", "urgent"}
            diff == 1 -> {"1 día restante", ""}
            true -> {"#{diff} días restantes", ""}
          end

        _ ->
          {"", ""}
      end

    """
    <div class="card">
      <div class="card-header">
        <div class="card-title">#{name}</div>
        <button class="card-delete" onclick="del('#{id}')">✕</button>
      </div>
      <div class="countdown #{countdown_class}">#{countdown_text}</div>
      <div class="card-details">
        <span>📅 #{date_str}</span>
        <span>🔔 #{days} días</span>
      </div>
    </div>
    """
  end

  defp modal do
    autostart = EventTimer.AutoStart.enabled?()

    """
    <div id="modal" class="modal-overlay" onclick="closeModal('modal')">
      <div class="modal" onclick="event.stopPropagation()">
        <h2>Agregar Evento</h2>
        <input type="hidden" id="eid">
        <div class="form-group">
          <label>Nombre del Evento</label>
          <input type="text" id="ename" placeholder="Cumpleaños, Aniversario, etc." required>
        </div>
        <div class="form-group">
          <label>Fecha</label>
          <input type="date" id="edate" required>
        </div>
        <div class="form-group">
          <label>Descripción (opcional)</label>
          <textarea id="edesc" placeholder="Detalles adicionales..."></textarea>
        </div>
        <div class="form-group">
          <label>Días de anticipación</label>
          <input type="number" id="edays" value="7" min="1" max="30">
        </div>
        <div class="modal-actions">
          <button class="btn btn-sec" onclick="closeModal('modal')">Cancelar</button>
          <button class="btn" onclick="save()">Guardar</button>
        </div>
      </div>
    </div>

    <div id="settingsModal" class="modal-overlay" onclick="closeModal('settingsModal')">
      <div class="modal" onclick="event.stopPropagation()">
        <h2>Configuración</h2>
        <div class="switch">
          <label class="switch-label">
            <h4>Iniciar con Windows</h4>
            <p>Ejecutar automáticamente al iniciar sesión</p>
          </label>
          <input type="checkbox" id="autostart" #{if autostart, do: "checked", else: ""} onchange="toggleAutoStart(this)">
          <label class="toggle" for="autostart"></label>
        </div>
        <div class="modal-actions">
          <button class="btn" onclick="closeModal('settingsModal')">Aceptar</button>
        </div>
      </div>
    </div>
    """
  end

  defp parse_date(date_str) when is_binary(date_str) do
    Date.from_iso8601(date_str)
  end

  defp parse_date(_), do: {:error, :invalid}
end
