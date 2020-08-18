fn main()
{
	let start = std::time::SystemTime::now();
	loop
	{
		std::thread::sleep( std::time::Duration::from_millis( 500 ) );
		println!( "hi, millis {}", start.elapsed().unwrap().as_millis() );
		println!( "{}[38;2;200;0;200m{}", 27 as char, "bye" );
	}
}
