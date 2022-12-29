module main

import gg
import gx
import os
// import math
import time
// import rand
import json

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
	pos     Vec2
	old_pos Vec2
	dir     Direction
	speed   int
	width   int
	height  int
	image   int
}

struct Simultus {
mut:
	pos    Vec2
	width  int
	height int
	image  int
}

struct EnvTile {
mut:
	pos Vec2
	dim Vec2
}

struct Enviroment {
mut:
	tiles []EnvTile
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
	env    Enviroment
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
		old_pos: Vec2{
			x: 0
			y: 0
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
	map_path := os.resource_abs_path(os.join_path('rsc', 'maps', 'map.json'))
	raw_json := os.read_file(map_path) or { panic(err) }
	game.env.tiles = json.decode([]EnvTile, raw_json) or {
		eprintln('Failed to decode json, error: ${err}')
		return
	}
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

fn check_boundarys(mut game Game) {
	if game.player.pos.x - game.player.width / 2 < 0 {
		game.player.pos.x = 0 + game.player.width / 2
	} else if game.player.pos.x + game.player.height / 2 > game.gg.width {
		game.player.pos.x = game.gg.width - game.player.width / 2
	}
	if game.player.pos.y - game.player.height / 2 < 0 {
		game.player.pos.y = 0 + game.player.height / 2
	} else if game.player.pos.y + game.player.height / 2 > game.gg.height / 2 {
		game.player.pos.y = game.gg.height / 2 - game.player.height / 2
	}
}

fn player_tile_collision_check(player Player, tile EnvTile) bool {
	return player.pos.x < tile.pos.x + tile.dim.x && player.pos.x + player.width > tile.pos.x
		&& player.pos.y < tile.pos.y + tile.dim.y && player.pos.y + player.height > tile.pos.y
}

fn sim_tile_collision_check(player Simultus, tile EnvTile) bool {
	return player.pos.x < tile.pos.x + tile.dim.x && player.pos.x + player.width > tile.pos.x
		&& player.pos.y < tile.pos.y + tile.dim.y && player.pos.y + player.height > tile.pos.y
}

fn check_tile_collision(mut game Game) {
	for tile in game.env.tiles {
		collision1 := player_tile_collision_check(game.player, tile)
		collision2 := sim_tile_collision_check(game.sim, tile)
		if collision1 == true {
			game.player.pos.x = game.player.old_pos.x
			game.player.pos.y = game.player.old_pos.y
			game.sim.pos.x = game.player.old_pos.x
			game.sim.pos.y = game.player.old_pos.y - game.gg.height / 2
		} else if collision2 == true {
			game.player.pos.x = game.player.old_pos.x
			game.player.pos.y = game.player.old_pos.y
			game.sim.pos.x = game.player.old_pos.x
			game.sim.pos.y = game.player.old_pos.y - game.gg.height / 2
		}
	}
}

fn check_movement(mut game Game) {
	check_boundarys(mut game)
	check_tile_collision(mut game)
}

fn move_player(mut game Game, movement Vec2) {
	game.player.old_pos.x = game.player.pos.x
	game.player.old_pos.y = game.player.pos.y
	game.player.pos.x += movement.x * game.player.speed
	game.player.pos.y += movement.y * game.player.speed
}

fn move_sim(mut game Game) {
	game.sim.pos.x = game.player.pos.x
	game.sim.pos.y = game.player.pos.y + game.gg.height / 2
}

fn move_all(mut game Game) {
	mut movement_player := calc_player_move(mut game)
	move_player(mut game, movement_player)
	move_sim(mut game)
	check_movement(mut game)
}

fn (game &Game) update(mut mutgame Game) {
	move_all(mut mutgame)
	// println(game.player.dir)
	// println(game.player.pos)
}

fn player_draw(game &Game) {
	game.gg.draw_rect_filled(game.player.pos.x, game.player.pos.y, game.player.width,
		game.player.height, gx.blue)
}

fn sim_draw(game &Game) {
	game.gg.draw_rect_filled(game.sim.pos.x, game.sim.pos.y, game.sim.width, game.sim.height,
		gx.red)
}

fn boundarys_draw(game &Game) {
	game.gg.draw_line(0, game.gg.height / 2, game.gg.width, game.gg.height / 2, gx.black)
}

fn tiles_draw(game &Game) {
	for tile in game.env.tiles {
		game.gg.draw_rect_empty(tile.pos.x, tile.pos.y, tile.dim.x, tile.dim.y, gx.green)
	}
}

fn env_draw(game &Game) {
	boundarys_draw(game)
	tiles_draw(game)
}

fn (game &Game) draw() {
	game.gg.begin()
	env_draw(game)
	player_draw(game)
	sim_draw(game)
	game.gg.end()
}
