IO.puts "--- Probando Sensor Web (Bitcoin) ---"
case SensorWeb.precio_bitcoin() do
  {:ok, percepto} ->
    IO.puts "✅ ÉXITO"
    IO.inspect(percepto)
  {:error, razon} ->
    IO.puts "❌ ERROR"
    IO.puts "Razón: #{inspect(razon)}"
end
