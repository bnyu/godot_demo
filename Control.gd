extends Control

var is_show = false
var m_pos = Vector2()
var m_pos_p = Vector2()
const box_line_color = Color(0, 1, 0)
const box_line_width = 3

func _draw():
	if is_show and m_pos_p != m_pos:
		draw_line(m_pos_p, Vector2(m_pos.x, m_pos_p.y), box_line_color, box_line_width)
		draw_line(m_pos_p, Vector2(m_pos_p.x, m_pos.y), box_line_color, box_line_width)
		draw_line(m_pos, Vector2(m_pos.x, m_pos_p.y), box_line_color, box_line_width)
		draw_line(m_pos, Vector2(m_pos_p.x, m_pos.y), box_line_color, box_line_width)

func _process(delta):
	update()
