defmodule TaxiBeWeb.TaxiAllocationJob do
  use GenServer

  def start_link(request, name) do
    GenServer.start_link(__MODULE__, request, name: name)
  end

  def init(request) do
    Process.send(self(), :step1, [:nosuspend])
    {:ok, %{request: request,
            accepted_taxi: nil}}
  end

def compute_ride_fare(request) do
  %{
    "pickup_address" => pickup_address,
    "dropoff_address" => dropoff_address
   } = request

