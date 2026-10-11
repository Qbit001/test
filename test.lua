Quick heads-up: from this chat I can’t reach Melty’s tools or your PC’s game folders, so I can’t run game_info or search_mashups yet, and I can’t build, test or publish from here. For that, paste this same prompt into a coding agent like Claude Code or Codex that runs on your PC. I can still help you shape the design now so it’s ready to build.

First question: what is the mashup in one sentence?

What's the core idea of the Slime Rancher x Binding of Isaac mashup?
Recommended: Isaac-style roguelike rooms inside Slime Rancher: clear rooms with the vacpack, slimes are the enemies, Isaac's items become pickups
What should Isaac bring into the mashup, read from the player's own copy of the game?
Recommended: Isaac's items (names, icons, effects) as pickups, plus his sound effects and music in the rooms

Got it: the items, sounds and music all load from each player’s own Isaac install, so nothing is copied.

Next question: what does the player do in the first minute?

What happens in the player's first minute?
Recommended: Step through a door from the ranch into a sealed room, and slimes spawn in waves; vacuum or shoot them all to open the exits
Solo or with friends, and how should it be licensed and shared?
Recommended: Solo, open for remixing, credited to you, with a permissive license such as MIT

That’s everything I need on the design. Here is the first playable version, which I’ve decided myself:

Slime Rancher × Isaac: Sealed Rooms. You play inside Slime Rancher. A ranch door leads into a sealed room, and slimes spawn in waves. Clearing them with the vacpack opens the exits and drops an Isaac item pickup. The items and their names, icons and effects, plus Isaac’s sounds and music, load from each player’s own Isaac install, so nothing is copied or shipped. It’s solo, MIT-licensed, credited to you, and open for remixing.

Where this stands: I can’t build it from this chat. I have no connection to Melty and no access to your PC’s game folders, and there’s nowhere here to run or test the games. That means I haven’t been able to check what’s already on Melty or what Melty says about these two games.

There are also two real obstacles to plan around:

Isaac isn’t in Melty’s catalog. It would be a companion game found in your installed games. The mod would read its item data and audio files from that folder.
Slime Rancher has no loader that Melty installs by itself. The mod would need a Unity route such as BepInEx, which Melty would need to be able to install for players. A one-click check on that is needed before building.

To get it built: paste your original Melty prompt into Claude Code or Codex on the PC with both games installed. Add a line at the end with the design above, and it will skip the questions and start building. I’ve saved the design notes, so I can help you refine them or write that line if you’d like.
