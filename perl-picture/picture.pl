#!/usr/bin/perl -w
use strict;
use Tk;

# vector
sub make_vect {
	my ($x, $y) = @_;
	return [$x, $y];
}
sub xcor_vect {
	my $vector = shift;
	return $vector->[0];
}
sub ycor_vect {
	my $vector = shift;
	return $vector->[1];
}
sub add_vect {
	my ($vector1, $vector2) = @_;
	make_vect(xcor_vect($vector1) + xcor_vect($vector2),
			  ycor_vect($vector1) + ycor_vect($vector2));
}
sub sub_vect {
	my ($vector1, $vector2) = @_;
	make_vect(xcor_vect($vector1) - xcor_vect($vector2),
              ycor_vect($vector1) - ycor_vect($vector2));
}
sub scale_vect {
	my ($scale, $vector) = @_;
	make_vect(xcor_vect($vector) * $scale,
    		  ycor_vect($vector) * $scale);
}

# frame
sub make_frame {
	my ($origin_frame, $edge1_frame, $edge2_frame) = @_;
	return [$origin_frame, $edge1_frame, $edge2_frame];
}
sub origin_frame {
	my $frame = shift;
	return $frame->[0];
}
sub edge1_frame {
	my $frame = shift;
	return $frame->[1];
}
sub edge2_frame {
	my $frame = shift;
	return $frame->[2];
}

# segment
sub make_segment {
	my ($point1, $point2) = @_;
	return [$point1, $point2];
}
sub start_segment {
	my $segment = shift;
	return $segment->[0];
}
sub end_segment {
	my $segment = shift;
	return $segment->[1];
}


sub segments_painter {
	my $canvas = shift;
	my @segment_list = @_;

	return sub {
		my ($frame) = @_;
		foreach my $segment (@segment_list) {
			my $segment2 = make_segment(
					make_vect(xcor_vect(start_segment($segment)),
						      1 - ycor_vect(start_segment($segment))),
					make_vect(xcor_vect(end_segment($segment)),
						      1 - ycor_vect(end_segment($segment))));
			my $start
                = frame_coord_map($frame)->(start_segment($segment2));
			my $end = frame_coord_map($frame)->(end_segment($segment2));
			$canvas->create('line', @$start, @$end);
			$canvas->pack();
		}
	}
}

sub gcd {
    my ($x, $y) = @_;

	if ($x > $y) {
	    ($x, $y) = ($y, $x);
	}

	while ($y != 0) {
	    ($x, $y) = ($y, $x % $y);
	}

	return $x;
}

sub picture_painter_1 {
	my ($canvas, $image) = @_;

	return sub {
		my $frame = shift;
		my $start = frame_coord_map($frame)->([0, 0]);
		my $end   = frame_coord_map($frame)->([1, 1]);
		my $x     = abs(xcor_vect($end) - xcor_vect($start));
		my $y     = abs(ycor_vect($end) - ycor_vect($start));

		my $image2 = $canvas->Photo();
        my $image3 = $canvas->Photo();
		my $gcd_x  = gcd($x, $image->width);
		if ($x > $image->width) {
		    $image2->copy($image, -zoom=>($x/$gcd_x, 1));
		    $image3->copy($image2,  -subsample=>($image->width/$gcd_x, 1));
		}
		else {
		    $image2->copy($image, -zoom=>($image->width/$gcd_x, 1));
		    $image3->copy($image2,  -subsample=>($x/$gcd_x, 1));
		}

        my $image4 = $canvas->Photo();
        my $image5 = $canvas->Photo();
		my $gcd_y  = gcd($y, $image->height);
		if ($y > $image->height) {
		    $image4->copy($image3, -zoom=>(1, $y/$gcd_y));
		    $image5->copy($image4, -subsample=>(1, $image->height/$gcd_y));
		}
		else {
		    $image4->copy($image3, -zoom=>(1, $image->height/$gcd_y));
		    $image5->copy($image4, -subsample=>(1, $y/$gcd_y));
		}

		$canvas->create('image', xcor_vect($start), ycor_vect($start), -anchor=>"nw",
				-image=>$image5);
	}
}

sub picture_painter_2 {
	my ($canvas, $image) = @_;

	return sub {
		my $frame = shift;
		my $start = frame_coord_map($frame)->([0, 0]);
		my $end   = frame_coord_map($frame)->([1, 1]);
		my $x     = abs(xcor_vect($end) - xcor_vect($start));
		my $y     = abs(ycor_vect($end) - ycor_vect($start));

		my $image2 = $canvas->Photo();
		if ($x > $image->width) {
		    $image2->copy($image, -zoom=>($x/$image->width, 1));
		}
		else {
		    $image2->copy($image, -subsample=>($image->width/$x, 1));
		}

        my $image3 = $canvas->Photo();
		if ($y > $image->height) {
		    $image3->copy($image2, -zoom=>(1, $y/$image->height));
		}
		else {
		    $image3->copy($image2, -subsample=>(1, $image->height/$y));
		}

		$canvas->create('image', xcor_vect($start), ycor_vect($start), -anchor=>"nw",
				-image=>$image3);
	}
}
sub frame_coord_map {
	my $frame = shift;

	return sub {
		my $v = shift;
		my $vector1
            = scale_vect(xcor_vect($v), edge1_frame($frame));
		my $vector2
            = scale_vect(ycor_vect($v), edge2_frame($frame));
		add_vect(origin_frame($frame),
                 add_vect($vector1, $vector2));
	}
}

sub transform_painter {
	my ($painter, $origin, $corner1, $corner2) = @_;

	return sub {
		my $frame = shift;
		my $m = frame_coord_map($frame);
		my $new_origin = $m->($origin);

		$painter->(make_frame($new_origin,
                              sub_vect($m->($corner1), $new_origin),
                              sub_vect($m->($corner2), $new_origin)));
	}
}

sub flip_vert {
	my $painter = shift;
	transform_painter($painter, make_vect(0.0, 1.0),
			make_vect(1.0, 1.0), make_vect(0.0, 0.0));
}

sub flip_horiz {
	my $painter = shift;
	transform_painter($painter, make_vect(1.0, 0.0),
			make_vect(0.0, 0.0), make_vect(1.0, 1.0));
}

sub beside {
	my ($painter1, $painter2) = @_;
	my $split_point = make_vect(0.5, 0.0);
	my $paint_left = transform_painter($painter1, make_vect(0.0, 0.0), $split_point, make_vect(0.0, 1.0));
	my $paint_right = transform_painter($painter2, $split_point, make_vect(1.0, 0.0), make_vect(0.5, 1.0));
	return sub {
		my $frame = shift;
		$paint_left->($frame);
		$paint_right->($frame);
	}
}

sub below {
	my ($painter1, $painter2) = @_;

	my $split_point = make_vect(0.0, 0.5);
	my $paint_low   = transform_painter($painter1, $split_point, make_vect(1.0, 0.5), make_vect(0.0, 1.0));
	my $paint_up    = transform_painter($painter2, make_vect(0.0, 0.0), make_vect(1.0, 0.0), $split_point);
	return sub {
		my $frame = shift;
		$paint_up->($frame);
		$paint_low->($frame);
	}
}

sub right_split {
	my ($painter, $n) = @_;
	if ($n == 0) {
		return $painter;
	}
	else {
		my $smaller = right_split($painter, $n-1);
		beside($painter, below($smaller, $smaller));
	}
}

sub up_split {
	my ($painter, $n) = @_;
	if ($n == 0) {
		return $painter;
	}
	else {
		my $smaller = up_split($painter, $n-1);
		below($painter, beside($smaller, $smaller));
	}
}

sub corner_split {
	my ($painter, $n) = @_;
	if ($n == 0) {
		return $painter;
	}
	else {
		my $up = up_split($painter, $n-1);
		my $right = right_split($painter, $n-1);
		my $top_left = beside($up, $up);
		my $bottom_right = below($right, $right);
		my $corner = corner_split($painter, $n-1);
		beside(below($painter, $top_left),
				below($bottom_right, $corner));
	}
}

sub square_limit {
	my ($painter, $n) = @_;
	my $quarter = corner_split($painter, $n);
	my $half = beside(flip_horiz($quarter), $quarter);
	below(flip_vert($half), $half);
}

sub rotate90 {
	my $painter = shift;
	transform_painter($painter,
					   make_vect(1.0, 0.0),
					   make_vect(1.0, 1.0),
					   make_vect(0.0, 0.0));
}

sub squash_inwards {
	my $painter = shift;
	transform_painter($painter,
			           make_vect(0.0, 0.0),
					   make_vect(0.65, 0.35),
					   make_vect(0.35, 0.65));
}

1;
