defmodule Pantheon.EventStore do
  @moduledoc """
  EventStore configuration for the Pantheon application.
  """
  use EventStore, otp_app: :pantheon
end
