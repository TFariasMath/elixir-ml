defmodule SensorWeb do
  @moduledoc """
  Componente de percepción digital. Transforma datos del entorno
  web (APIs, HTML) en perceptos estructurados para un agente.
  """

  @doc """
  Obtiene el precio actual de Bitcoin desde la API pública de CoinGecko.
  Retorna un mapa con el percepto estructurado.
  """
  def precio_bitcoin do
    url = "https://api.coingecko.com/api/v3/simple/price" <>
          "?ids=bitcoin&vs_currencies=usd&include_24hr_change=true"

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        btc = body["bitcoin"]
        {:ok, %{
          asset: "bitcoin",
          precio_usd: btc["usd"],
          cambio_24h: Float.round((btc["usd_24h_change"] || 0.0) * 1.0, 2),
          timestamp: DateTime.utc_now()
        }}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, exception} ->
        {:error, Exception.message(exception)}
    end
  end

  @doc """
  Sensor genérico: extrae texto de una página web usando un selector CSS.
  """
  def scrape_texto(url, selector) do
    case Req.get(url) do
      {:ok, %{status: 200, body: html}} when is_binary(html) ->
        texto =
          html
          |> Floki.parse_document!()
          |> Floki.find(selector)
          |> Floki.text()
          |> String.trim()

        {:ok, texto}

      {:ok, %{status: _status, body: body}} when is_map(body) ->
        {:ok, inspect(body)}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, exception} ->
        {:error, Exception.message(exception)}
    end
  end
end
