export type Telescope = {
    focusing: "in" | "out" | "no"
    home_az: boolean
    lower_alt_stop: boolean
    lower_focus_stop: boolean
    moving: "no" | "up" | "down" | "right" | "left"
    name: string
    position_alt: number
    position_az: number
    position_focus: number
    upper_alt_stop: boolean
    upper_focus_stop: boolean
}