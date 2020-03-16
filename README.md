Config scripts to enable audio streaming on Raspberry Pi using [forked-daapd](https://github.com/ejurgensen/forked-daapd/) and [cpiped](https://github.com/b-fitzpatrick/cpiped/)

# Setup

1. On installation machine run 
```sh
sudo apt-get install git
git clone git@github.com:jwallin/vinyl-streamer-config.git
cd vinyl-streamer-config
```
3. Update configuration properties in setup.sh. To obtain output device, run `aplay -l`.
4. Set up config by running 
`sudo ./setup.sh`

Based on [https://github.com/ejurgensen/forked-daapd/issues/632](https://github.com/ejurgensen/forked-daapd/issues/632)

