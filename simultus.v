module main

import gg
import gx

struct Player {
mut:
	x int
	y int
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
		frame_fn: frame
		init_fn: init
	)
	game.gg.run()
}

fn init(mut game Game) {
	game.player = Player{
		x: 100
		y: 100
	}
}

fn frame(game &Game) {
	game.draw()
}

fn (game &Game) draw() {
	game.gg.begin()
	game.gg.draw_triangle_filled(450, 142, 530, 280, 370, 280, gx.red)
	game.gg.end()
}
