// RUN: %target-parse-verify-swift

// XFAIL: linux

import Foundation

// Common pitfall: trying to subscript a string with integers.
func testIntSubscripting(s: String, i: Int) {
  // FIXME swift-3-indexing-model: test new overloads of ..<, ...
  _ = s[i] // expected-error{{'subscript' is unavailable: cannot subscript String with an Int, see the documentation comment for discussion}}
  _ = s[17] // expected-error{{'subscript' is unavailable: cannot subscript String with an Int, see the documentation comment for discussion}}
  _ = s[i...i] // expected-error{{subscript' is unavailable: cannot subscript String with a CountableClosedRange<Int>, see the documentation comment for discussion}}
  _ = s[17..<20] // expected-error{{subscript' is unavailable: cannot subscript String with a CountableRange<Int>, see the documentation comment for discussion}}
  _ = s[17...20] // expected-error{{subscript' is unavailable: cannot subscript String with a CountableClosedRange<Int>, see the documentation comment for discussion}}
}

// Common pitfall: trying to access `String.count`.
func testStringCount(s: String) {
  _ = s.count // expected-error{{'count' is unavailable: there is no universally good answer, see the documentation comment for discussion}}
}

func testNonAmbiguousStringComparisons() {
  let s1 = "a"
  let s2 = "b"
  var x = false // expected-warning {{variable 'x' was written to, but never read}}
  x = s1 > s2
  x = s1 as String > s2
}

func testAmbiguousStringComparisons(s: String) {
  let nsString = s as NSString
  let a1 = s == nsString
  let a2 = s != nsString
  let a3 = s < nsString // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{24-24= as String}}
  let a4 = s <= nsString // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{25-25= as String}}
  let a5 = s >= nsString // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{25-25= as String}}
  let a6 = s > nsString // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{24-24= as String}}
  // now the other way
  let a7 = nsString == s
  let a8 = nsString != s
  let a9 = nsString < s // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{20-20= as String}}
  let a10 = nsString <= s // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{21-21= as String}}
  let a11 = nsString >= s // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{21-21= as String}}
  let a12 = nsString > s // expected-error{{'NSString' is not implicitly convertible to 'String'; did you mean to use 'as' to explicitly convert?}} {{21-21= as String}}
}

func acceptsSequence<S : Sequence>(_ sequence: S) {}

func testStringIsNotASequence(s: String) {
  acceptsSequence(s) // expected-error {{argument type 'String' does not conform to expected type 'Sequence'}}
}

func testStringDeprecation(hello: String) {
  let hello2 = hello
    .addingPercentEscapes(usingEncoding: NSUTF8StringEncoding) // expected-warning{{'addingPercentEscapes(usingEncoding:)' is deprecated}}

  _ = hello2?
    .replacingPercentEscapes(usingEncoding: NSUTF8StringEncoding) // expected-warning{{'replacingPercentEscapes(usingEncoding:)' is deprecated}}


}

// Positive and negative tests for String collection types
func acceptsCollection<I: Collection>(_: I) {}
func acceptsBidirectionalCollection<I: BidirectionalCollection>(_: I) {}
func acceptsRandomAccessCollection<I: RandomAccessCollection>(_: I) {}

func testStringCollectionTypes(s: String) {
  acceptsCollection(s.utf8)
  acceptsBidirectionalCollection(s.utf8) // expected-error{{argument type 'String.UTF8View' does not conform to expected type 'BidirectionalCollection'}}
  acceptsBidirectionalCollection(s.unicodeScalars)
  acceptsRandomAccessCollection(s.unicodeScalars) // expected-error{{argument type 'String.UnicodeScalarView' does not conform to expected type 'RandomAccessCollection'}}
  acceptsBidirectionalCollection(s.characters)
  acceptsRandomAccessCollection(s.characters) // expected-error{{argument type 'String.CharacterView' does not conform to expected type 'RandomAccessCollection'}}
  
  // UTF16View.Collection is random-access with Foundation, bidirectional without
  acceptsRandomAccessCollection(s.utf16)
}

