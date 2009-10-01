//------------------------------------------------------------------------
//
//  Visibility Buffer
//
//  Copyright (C) 2009 Andrew Apted
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//------------------------------------------------------------------------

#ifndef __OBLIGE_VIS_BUFFER_H__
#define __OBLIGE_VIS_BUFFER_H__


// map data
#define V_BOTTOM  0x0001
#define V_LEFT    0x0002 


// vis results
#define V_BASIC   0x0010   // ultra basic
#define V_SPAN    0x0020   // long spans
#define V_LSHAPE  0x0040   // L shape testing
#define V_FILL    0x0080

#define V_ANY     0xFFF0


struct Stair_Pos
{
	short x, y, side;
};

typedef std::vector<Stair_Pos> Stair_Steps;


class Vis_Buffer
{
private:
	int W, H;  // size

	short * data;

	bool quick_mode;

	// square we are processing
	int loc_x, loc_y;

	// current transform
	int flip_x, flip_y;

	// current limits for DoSteps()
	int limit_x, limit_y;

public:
	Vis_Buffer(int width, int height) :
    	W(width), H(height), quick_mode(false),
		flip_x(0), flip_y(0)
	{
		data = new short[W * H];

		Clear();
	}

	~Vis_Buffer()
	{
		delete[] data;
	}

public:
	inline int Trans_X(int x)
	{
		return flip_x ? (loc_x * 2 - x) : x;
	}

	inline int Trans_Y(int y)
	{
		return flip_y ? (loc_y * 2 - y) : y;
	}

	inline int Trans_Side(int side)
	{
		if ( (flip_x && (side == 4 || side == 6)) ||
		     (flip_y && (side == 2 || side == 8)) )
		{
			return 10 - side;
		}
		return side;
	}

	inline bool isValid(int x, int y)
	{
		x = Trans_X(x);
		y = Trans_Y(y);

		return (0 <= x && x < W) && (0 <= y && y < H);
	}

	inline short& at(int x, int y)
	{
		x = Trans_X(x);
		y = Trans_Y(y);

		return data[y * W + x];
	}

public:
	void Clear();
	void SetQuickMode(bool enable);

	void AddWall( int x, int y, int side);
	bool TestWall(int x, int y, int side);

	void ReadMap(const char *filename);

	void ClearVis();
	void ProcessVis(int x, int y);
	int GetVis(int x, int y);

private:
	void AddStep(Stair_Steps& dest, int x, int y, int side);
	void CopySteps(Stair_Steps& dest, const Stair_Steps& src);
	void MarkSteps(const Stair_Steps& steps);
	void FollowStair(Stair_Steps& steps, int sx, int sy, int side);

	void DoBasic(int dx, int dy, int side);
	void DoFill();
	void DoSteps(int quadrant);
};

#endif /* __OBLIGE_VIS_BUFFER_H__ */

//--- editor settings ---
// vi:ts=2:sw=2:expandtab
