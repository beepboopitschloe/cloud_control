defmodule CloudControlServer.DigitalOceanClient do
  @api_url "https://api.digitalocean.com/v2"
  @api_key "BEARER #{Application.fetch_env! :cloud_control_server, :digital_ocean_key}"
  @root_ssh_key_id Application.fetch_env! :cloud_control_server, :do_root_ssh_key_id
  @client_node_cookie Node.get_cookie
  @client_node_port 9000

  # TODO don't hardcode this
  @user_data_script """
  #!/bin/bash

  LOGFILE=/var/log/user-data-script.log
  ERRFILE=/var/log/user-data-script.err.log

  PACKAGES="build-essential git-core curl esl-erlang elixir"

  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb

  sudo apt-get update > $LOGFILE 2>$ERRFILE
  sudo apt-get install -y $PACKAGES > $LOGFILE 2> $ERRFILE

  git clone https://git.noahmuth.com/nmuth/cloud_control.git > $LOGFILE 2> $ERRFILE
  cd cloud_control/apps/cloud_control_client

  # get IP address of the node
  ip=$(dig +short myip.opendns.com @resolver1.opendsn.com)

  iex -S mix --name \"#{__MODULE__}@$ip\" \
    --cookie #{@client_node_cookie} \
    --erl '-kernel inet_dist_listen_min #{@client_node_port}' \
    --erl '-kernel inet_dist_listen_max #{@client_node_port}' > $LOGFILE 2> $ERRFILE
  """

  def get_droplets do
    get "droplets"
  end

  def create_droplet name do
    body = %{
      region: "nyc2",
      size: "512mb",
      image: "ubuntu-14-04-x64",
      user_data: @user_data_script,
      name: name,
      ssh_keys: [@root_ssh_key_id]
    }

    post "droplets", body
  end

  defp get path do
    url = "#{@api_url}/#{path}"
    headers = [
      authorization: @api_key
    ]

    HTTPoison.get url, headers
  end

  defp post path, body do
    url = "#{@api_url}/#{path}"
    headers = %{
      "Authorization" => @api_key,
      "Content-Type" => "application/json"
    }
    {:ok, json_body} = Poison.encode(body)

    IO.puts "headers: #{inspect headers}"

    HTTPoison.post url, json_body, headers
  end

  defp parse_json_body body do
    Poison.Parser.parse body
  end
end
