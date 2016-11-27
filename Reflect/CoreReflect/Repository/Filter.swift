//
// Filter.swift
// CoreReflect
//
// Created by Bruno Fernandes on 18/03/16.
// Copyright © 2016 BFS. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

public enum Filter {
    case compare(String, Comparison, Value?)
    case subset(String, Comparison, [Value?])
    case group(Operation, [Filter])
    case order(String, Sort)
    case union(Join, String, String, Comparison, String)
}

public enum Comparison: CustomStringConvertible {
    case equals, greaterThan, lessThan, notEquals, `in`, notIn, `is`, like, notLike ,between
    
    public var description: String {
        switch self {
        case .equals:
            return "="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        case .notEquals:
            return "!="
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        case .is:
            return "IS"
        case .like:
            return "LIKE"
        case .notLike:
            return "NOT LIKE"
        case .between:
            return "BETWEEN"
        }
    }
}

public enum Operation: CustomStringConvertible {
    case and, or
    
    public var description: String {
        switch self {
        case .and:
            return "AND"
        case .or:
            return "OR"
        }
    }
}

public enum Join: CustomStringConvertible {
    case inner, right, left
    
    public var description: String {
        switch self {
        case .inner:
            return "INNER JOIN"
        case .left:
            return "LEFT JOIN"
        case .right:
            return "RIGHT JOIN"
        }
    }
}

public enum Sort: CustomStringConvertible {
    case asc, desc
    
    public var description: String {
        switch self {
        case .asc:
            return "ASC"
        case .desc:
            return "DESC"
        }
    }
}

public enum Pagination: CustomStringConvertible {
    case limit(Int), offset(Int)
    
    public var description: String {
        switch self {
        case .limit(let count):
            return "LIMIT \(count)"
        case .offset(let count):
            return "OFFSET \(count)"
        }
    }
}

public enum Aggregate: CustomStringConvertible {
    case `default`, count(String), average(String), max(String), min(String), sum(String)
    
    public var description: String {
        switch self {
        case .default:
            return "*"
        case .count(let field):
            return "COUNT(\(field)) AS \(self.field)"
        case .average(let field):
            return "AVG(\(field)) AS \(self.field)"
        case .max(let field):
            return "MAX(\(field)) AS \(self.field)"
        case .min(let field):
            return "MIN(\(field)) AS \(self.field)"
        case .sum(let field):
            return "SUM(\(field)) AS \(self.field)"
        }
    }
    
    public var field: String {
        switch self {
        case .default:
            return "default"
        case .count:
            return "count"
        case .average:
            return "average"
        case .max:
            return "maximum"
        case .min:
            return "minimum"
        case .sum:
            return "value"
        }
    }
}
