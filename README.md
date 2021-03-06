# LOL Summoner Match Monitor

Thanks for looking! Feel free to reach out with any questions.

## Up and Running

### Deps

#### Elixir:
I personally tested against v1.13.4 on OTP 24.3.3, and that's what the mixfile requires but it's pretty likely this will run fine on other versions, so feel free to change it if you feel the need.
            
#### Riot API Key
In order to run the app a Riot Games api key must be set in a system var (or you can override the application config if you prefer).

```bash
export RIOT_API_KEY=<your_secret_key>
```

### Running the Challenge Code

```bash
# get deps
> mix deps.get

# run the test suite
> mix test

# start the application
> iex -S mix
```
Then call the function with a valid summoner name and region:
```elixir
iex> SummonerMonitor.monitor_summoners("MSorenstein", "NA1")
```

I've made pretty liberal use of Logger throughout the code base,
if it's too chatty you can change the level to `:notice` and still catch the
necessary output. You can do so by editing the config
or executing the following in your iex session:
```
iex> Logger.configure(level: :notice)
```
