#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn rust_main() -> ! {
    let vga = 0xb8000 as *mut u8;

    unsafe {
        *vga.offset(0) = b'H';
        *vga.offset(1) = 0x0f;
    }

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
