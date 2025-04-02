# Acknowledgements

Thanks to the following who have contributed to this project:

* _**Guillermo Fazzolari**_ for the bug fix in v2.0.1.

* _**Laurent Pierre**_ supplied many `PRODUCT_*` constants and suggested the _GetProductInfo_ API code used in v3.0 and later.

* _**Rich Habedank**_ for the bug fix in Subversion revision 228 (now Git commit 1b7f58d) and testing some bug fixes.

The project also draws on the work of:

* _**Achim Kalwa**_ who translated the `versionhelpers.h` header into Pascal. Some of the _IsReallyWindowsXXXXOrGreater_ methods of _TPJOSInfo_ and the _TestWindowsVersion_ routine code are based closely on his work.

* _**Brendan Grant**_ for his ideas presented in the 2007 Code Project article "[Determining the specific edition of Windows for now and in the future](https://bit.ly/1mDKTu3)".

* _**Kendall Sullivan**_ for the code on which _TPJComputerInfo.IsAdmin_ is based. The code was published in his Embarcadero article "How to detect if the current user is logged in administrator" _(link broken)_.

* _**norgepaul**_ for the code on which _TPJComputerInfo.IsUACActive_ is based. See his answer to the Stack Overflow question "[Delphi Executing command line command](https://tinyurl.com/avlztmg)".

* _**Pavel Hruška**_ for the C# code on which _TPJOSInfo.DecodedDigitalProductIDWin8AndUp_ is based. This code is [MIT licensed](https://github.com/mrpeardotnet/WinProdKeyFinder/blob/master/LICENSE) and is copyright (c) 2020 Pavel Hruška. It was taken from [`KeyDecoder.cs`](https://github.com/mrpeardotnet/WinProdKeyFinder/blob/master/WinProdKeyFind/KeyDecoder.cs) from the [mrpeardotnet/WinProdKeyFinder](https://github.com/mrpeardotnet/WinProdKeyFinder) project on GitHub.

* _**Richard MacCutchan**_ for the C++ code on which _TPJOSInfo.DecodedDigitalProductIDWin7AndDown_ is based. The code was posted on
    CodeProject by _enhzflep_ as Solution 4 at to the question ["How to get productId in windows 7 64 bit"](https://tinyurl.com/3n7fbt3h).

* _**Strive Sun**_ for the C code presented in his answer to the Stack Overflow post ["Win32 API to get Machine UUID"](https://tinyurl.com/cvbx792t). A Pascal translation of some of this code was used as a basis for the portions of the _TPJBiosInfo_ class.
