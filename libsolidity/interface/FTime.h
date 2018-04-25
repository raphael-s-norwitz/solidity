/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
 * @author Killian <krr2125@columbia.edu>
 * @author Jiayang <prokingsley@gmail.com>
 * @author Raphael <raphael.s.norwitz@gmail.com>
 * @date 2017
 * A timing utility for debugging compiler performance
 */
#include <chrono>
#include <string>
#include <sstream>
#include <vector>


class TimeNode
{
public:
	TimeNode();
	std::string name;
	std::vector<TimeNode> children;
	void setBegin();
	void setEnd();
	const std::chrono::high_resolution_clock::time_point getBegin() const;
	const std::chrono::high_resolution_clock::time_point getEnd() const;
private:
	std::chrono::high_resolution_clock::time_point begin;
	std::chrono::high_resolution_clock::time_point end;
};

class TimeNodeStack
{
public:
	TimeNodeStack();
	~TimeNodeStack();
	void push(std::string name);
	std::string pop();
	std::string printString(bool tree);
	void print();
	void print_recursive(const TimeNode& x, const std::string& arrow, 
			std::stringstream& ss, bool tree);
        bool print_flag = false;
	bool tree = true;
private:
	std::vector<TimeNode> stack;
	std::vector<TimeNode> print_stack;
	std::chrono::high_resolution_clock::time_point start;
};

class TimeNodeWrapper
{
public:
	TimeNodeWrapper(TimeNodeStack& t_stack, std::string given_name);
	void pop();
	~TimeNodeWrapper();

private:
	std::string name;
	bool popped;
	TimeNodeStack& stack;
};

extern TimeNodeStack t_stack;
