(
	import
		"${builtins.getEnv( "MONO_ROOT" )}/Nix/rust.nix" 
		{}
).shellMaker {}


