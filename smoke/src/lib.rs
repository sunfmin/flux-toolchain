#[flux_rs::sig(fn(x: i32{x > 0}) -> i32{v: v > 0})]
pub fn keep(x: i32) -> i32 {
    x
}
