#!/bin/perl

open output,">rom.asm" or die "Lies! Lies!";
print output "rom0: \n";

$in = <STDIN>;
chop $in;
open input,"<",$in or die "Lies! Lies!";

while(<input>)
{
    $in = $_;
    @in = split(' ',$in);
    &asm;
}

print output "db 00\r\n";
close(output);

sub asm
{
    &mov if @in[0] eq "mov";
    &add if @in[0] eq "add";
    &inc if @in[0] eq "inc";
    &sbt if @in[0] eq "sub";
    &dec if @in[0] eq "dec";
    &jmp if @in[0] eq "jmp";
    &cmp if @in[0] eq "cmp";
    &call if @in[0] eq "call";
    &wait if @in[0] eq "wait";
    &run if @in[0] eq "run";
    print output "db 10,",@in[1],"\r\n" if @in[0] eq "jne";
    print output "db 11,",@in[1],"\r\n" if @in[0] eq "je";    
    print output "db 12,",@in[1],"\r\n" if @in[0] eq "jg";
    print output "db 13,",@in[1],"\r\n" if @in[0] eq "jl";
    print output "db 06\r\n" if @in[0] eq "nop";
    print output "db 15\r\n" if @in[0] eq "ret";
}

sub mov
{
    @args = split(',',@in[1]);
    $a0 = @args[0];
    $a1 = @args[1];

    if ($a1 =~ /r/ or $a0 =~ /r/)
    {
	if ($a0 =~ /\[/ or $a1 =~ /\[/)
	{
	    if ($a1 =~ /\[/)
	    {
		chop($a1);
		print output "db 04,",(substr @args[0],1),",",(substr $a1,1),"\r\n";
	    }
	    else
	    {
		chop($a0);
		print output "db 05,",(substr $a0,1),",",(substr $a1,1),"\r\n";
	    }
	}
	else
	{
	    if ($a1 =~ /r/ and $a0 =~ /r/)
	    {
     	        $a0 = substr @args[0],1;
                $a1 = substr @args[1],1;
	        print output "db 09,",$a0,",",$a1,"\r\n";
	    }
	    else
	    {
		$a0 = substr @args[0],1;
		$a1 = @args[1];
		print output "db 01,",$a0,",",$a1,"\r\n";
	    }
	}
    }
}

sub add
{
    @args = split(',',@in[1]);
    
    if (!@args[0])
    {
	print output "db 20\r\n";
    }
    else
    {
	print output "db 22,",(substr @args[0],1),",",@args[1],"\r\n";
    }
}

sub inc
{
    $a0 = substr @in[1],1;
    print output "db 21,",$a0,"\r\n";
}

sub sbt
{
    @args = split(',',@in[1]);
    
    if (!@args[0])
    {
	print output "db 23\r\n";
    }
    else
    {
	print output "db 25,",(substr @args[0],1),",",@args[1],"\r\n";
    }
}

sub dec
{
    $a0 = substr @in[1],1;
    print output "db 24,",$a0,"\r\n";    
}

sub jmp
{
    print output "db 07,",@in[1],"\r\n";
}

sub cmp
{
    @args = split(',',@in[1]);
    $a0 = substr(@args[0],1);
    $a1 = @args[1];
    print output "db 08,",$a0,",",$a1,"\r\n";
}

sub call
{
    $a0 = @in[1];
    print output "db 14,",$a0,"\r\n";
}

sub wait
{
    @args = split(',',@in[1]);
    $a0 = @args[0];
    chop($a0);
    $a1 = @args[1];
    print output "db 16,",(substr $a0,1),",",$a1,"\r\n";
}

sub run
{
    $a0 = @in[1];

    if ($a0 =~ /^r/)
    {
	print output "db 17,255,",(substr $a0,1),"\r\n";
    }
    else
    {
	print output "db 17,",$a0,"\r\n";
    }
}
