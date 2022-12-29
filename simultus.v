module main

import gg
import gx
// import os

struct Direction {
mut:
	up    bool
	down  bool
	right bool
	left  bool
}

struct Player {
mut:
	x      int
	y      int
	dir    Direction
	width  int
	height int
	image  int
}

struct Game {
mut:
	gg     &gg.Context = unsafe { nil }
	player Player
}

fn main() {
	mut game := &Game{
		gg: 0
	}
	game.gg = gg.new_context(
		bg_color: gx.rgb(50, 50, 50)
		width: 600
		height: 400
		window_title: 'SIMULTUS'
		user_data: game
		frame_fn: frame
		init_fn: init
		keydown_fn: on_keydown
		keyup_fn: on_keyup
	)
	game.gg.run()
}

fn init(mut game Game) {
	game.player = Player{
		x: 100
		y: 100
		dir: Direction{
			up: false
			down: false
			right: false
			left: false
		}
		width: 32
		height: 32
	}
	// game.player.image = game.gg.create_image(os.resource_abs_path(os.join_path('rsc',
	//		'img', 'player.png'))).id
}

fn frame(mut game Game) {
	game.update(mut game)
	game.draw()
}

fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	match key {
		.w, .up {
			game.player.dir.up = true
		}
		.s, .down {
			game.player.dir.down = true
		}
		.a, .left {
			game.player.dir.left = true
		}
		.d, .right {
			game.player.dir.right = true
		}
		else {}
	}
}

fn on_keyup(key gg.KeyCode, mod gg.Modifier, mut game Game) {
	match key {
		.w, .up {
			game.player.dir.up = false
		}
		.s, .down {
			game.player.dir.down = false
		}
		.a, .left {
			game.player.dir.left = false
		}
		.d, .right {
			game.player.dir.right = false
		}
		else {}
	}
}

fn (game &Game) update(mut mutgame Game) {
	println(game.player.dir)
}

fn player_draw(game &Game) {
	game.gg.draw_circle_filled(game.player.x, game.player.y, game.player.width / 2, gx.blue)
}

fn (game &Game) draw() {
	game.gg.begin()
	player_draw(game)
	game.gg.end()
}
