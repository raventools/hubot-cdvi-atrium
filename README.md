# Hubot for CDVI Atrium

Control CDVI Atrium security systems. Current version unlocks a specified door.

See [`src/cdvi-atrium.coffee`](src/cdvi-atrium.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-cdvi-atrium --save`

Then add **hubot-cdvi-atrium** to your `external-scripts.json`:

```json
[
  "hubot-cdvi-atrium"
]
```

## Configuration

| Environment Variable    | Required? |                                        |
| ----------------------- | :-------: | ---------------------------------------------|
| `HUBOT_ATRIUM_URL`      | Yes       |  URL (without trailing slash) to Atrium web software |
| `HUBOT_ATRIUM_USERNAME` | Yes       |  Login username |
| `HUBOT_ATRIUM_PASSWORD` | Yes       |  Login password |
| `HUBOT_DOOR_IDS`        | Yes       |  Unique identifiers for doors |

### Note on `HUBOT_DOOR_IDS`

The door ID is not what is shown in the interface. Say, you have two doors:

```
00-00-42-13: Door 01
00-00-42-13: Door 02
```

The configuration variable instead would be the first part without the dashes, a colon and then the zero-index value of the door number. So instead, the doors above would become:

```
00004213:0
00004213:1
```

## Commands

To temporary unlock the door (like fob access):
```
User> hubot door or User> hubot door me
Hubot> Sending access command ...
Hubot> Door command sent!
```

To set door to be unlocked until reset command sent
```
User> hubot door unlock  or User> hubot door open
Hubot> Sending unlock command ...
Hubot> Door command sent!
```

To reset door to normal state
```
User> hubot door reset  or User> hubot door lock
Hubot> Sending reset command ...
Hubot> Door command sent!
```
