defmodule Pantheon.Supabase.Client do
  @moduledoc """
  Supabase client for interacting with Supabase services.
  """
  use Supabase.Client, otp_app: :pantheon
end
