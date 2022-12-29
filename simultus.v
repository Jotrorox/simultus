module main

import gg
import gx
// import os
// import math
import time
// import rand

struct Vec2 {
mut:
	x int
	y int
}

struct Direction {
mut:
	up    bool
	down  bool
	right bool
	left  bool
}

struct Player {
mut:
	pos    Vec2
	dir    Direction
	speed  int
	width  int
	height int
	image  int
}

struct Simultus {
mut:
	pos    Vec2
	width  int
	height int
	image  int
}

struct GameTime {
mut:
	tick_rate  int
	start_time i64
	last_tick  i64
}

struct Game {
mut:
	gg     &gg.Context = unsafe { nil }
	time   GameTime
	player Player
	sim    Simultus
}

fn main() {
	mut game := &Game{
		gg: 0
	}
	game.gg = gg.new_context(
		bg_color: gx.rgb(50, 50, 50)
		width: 800
		height: 800
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
		pos: Vec2{
			x: 100
			y: 100
		}
		dir: Direction{
			up: false
			down: false
			right: false
			left: false
		}
		speed: 3
		width: 32
		height: 32
	}
	// game.player.image = game.gg.create_image(os.resource_abs_path(os.join_path('rsc',
	//		'img', 'player.png'))).id
	game.sim = Simultus{
		pos: Vec2{
			x: 100
			y: 500
		}
		width: 32
		height: 32
	}
	// game.player.image = game.gg.create_image(os.resource_abs_path(os.join_path('rsc',
	//		'img', 'player.png'))).id
	game.time.start_time = time.ticks()
	game.time.last_tick = time.ticks()
}

fn frame(mut game Game) {
	tick_now := time.ticks()

	if tick_now - game.time.last_tick >= game.time.tick_rate {
		game.time.last_tick = tick_now
		game.update(mut game)
	}
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

fn calc_player_move(mut game Game) Vec2 {
	movement := Vec2{
		x: int(game.player.dir.right) - int(game.player.dir.left)
		y: int(game.player.dir.down) - int(game.player.dir.up)
	}
	return movement
}

fn move_player(mut game Game, movement Vec2) {
	game.player.pos.x += movement.x * game.player.speed
	game.player.pos.y += movement.y * game.player.speed
}

fn move_sim(mut game Game, movement Vec2) {
	game.sim.pos.x += movement.x * game.player.speed
	game.sim.pos.y += movement.y * game.player.speed
}

fn move_all(mut game Game) {
	mut movement_player := calc_player_move(mut game)
	move_player(mut game, movement_player)
	move_sim(mut game, movement_player)
}

fn (game &Game) update(mut mutgame Game) {
	move_all(mut mutgame)
	// println(game.player.dir)
	// println(game.player.pos)
}

fn player_draw(game &Game) {
	game.gg.draw_circle_filled(game.player.pos.x, game.player.pos.y, game.player.width / 2,
		gx.blue)
}

fn sim_draw(game &Game) {
	game.gg.draw_circle_filled(game.sim.pos.x, game.sim.pos.y, game.sim.width / 2, gx.red)
}

fn (game &Game) draw() {
	game.gg.begin()
	player_draw(game)
	sim_draw(game)
	game.gg.end()
}
