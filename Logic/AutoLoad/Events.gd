extends Node

## For global events that trigger audio / visual stuff

signal tile_hovered_long(tile)
signal tile_unhovered_long(tile)

#signal tile_hovered(tile)
signal tile_unhovered(tile)

signal tile_clicked(tile)
signal tile_click_released(tile)
signal tile_rightclicked(tile)

signal card_hovered(card)
signal card_selected(card)
signal pinned_card_clicked(card)
signal pinned_card_rightclicked(card)

signal energy_orb_clicked(orb)
signal energy_socket_clicked(socket)

var cards3d_ray_collision_point: Vector3
