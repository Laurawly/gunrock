Gunrock
=====================
Gunrock is a CUDA library for graph-processing designed specifically for the
GPU. It uses a high-level, bulk-synchronous, data-centric abstraction focused
on operations on a vertex or edge frontier. Gunrock achieves a balance between
performance and expressiveness by coupling high performance GPU computing
primitives and optimization strategies with a high-level programming model
that allows programmers to quickly develop new graph primitives with small
code size and minimal GPU programming knowledge.

For more details, please visit our **[website](http://gunrock.github.io/)**, read
[Why Gunrock](http://gunrock.github.io/gunrock/doc/latest/why-gunrock.html),
our paper on arXiv:
[Gunrock: A High-Performance Graph Processing Library on the GPU](http://arxiv.org/abs/1501.05387),
and check out the
[Publications](#Publications) section. See [Release Notes](http://gunrock.github.io/gunrock/doc/latest/release_notes.html) to keep up with the changes in latest release.

Getting Started with Gunrock
----------------------------
- For Frequently Asked Questions, see the
[FAQ](http://gunrock.github.io/gunrock/doc/latest/faq.html).

- For information on building Gunrock, see
[Building Gunrock](http://gunrock.github.io/gunrock/doc/latest/building_gunrock.html).

- The "tests" subdirectory included with Gunrock has a comprehensive test
application for most the functionality of Gunrock.

- For the programming model we use in Gunrock, see
[Programming Model](http://gunrock.github.io/gunrock/doc/latest/programming_model.html).

- To use our stats logging and performance chart generation pipeline, please check
out [Gunrock-to-JSON](http://gunrock.github.io/gunrock/doc/latest/gunrock_to_json.html).

- We have also provided code samples for how to use
[Gunrock's C interface](https://github.com/gunrock/gunrock/tree/master/shared_lib_tests)
and how to
[call Gunrock primitives from Python](https://github.com/gunrock/gunrock/tree/master/python),
as well as [annotated code](http://gunrock.github.io/gunrock/doc/annotated_primitives/annotated_primitives.html)
for two typical graph primitives.

- For details on upcoming changes and features, see the [Road Map](http://gunrock.github.io/gunrock/doc/latest/road_map.html).

Reporting Problems
----------------------------

To report Gunrock bugs or request features, please file an issue
directly using [Github](https://github.com/gunrock/gunrock/issues).

<!-- TODO: Algorithm Input Size Limitations -->


<a name="Publications"></a>
Publications
Leyuan Wang, Yangzihao Wang, Carl Yang, and John D. Owens. **A Comparative Study on Exact Triangle Counting Algorithms on the GPU**. In Proceedings of the 1st High Performance Graph Processing Workshop, HPGP '16, May 2016. 
[[DOI](http://dx.doi.org/10.1145/2915516.2915521) |
[http](http://www.escholarship.org/uc/item/9hf0m6w3)]

Yuechao Pan, Yangzihao Wang, Yuduo Wu, Carl Yang, and John D. Owens.
**Multi-GPU Graph Analytics**. CoRR, abs/1504.04804(1504.04804v2), April 2016.
[[arXiv](http://arxiv.org/abs/1504.04804)]

Yangzihao Wang, Andrew Davidson, Yuechao Pan, Yuduo Wu, Andy Riffel, and John D. Owens.
**Gunrock: A High-Performance Graph Processing Library on the GPU**.
In Proceedings of the 21st ACM SIGPLAN Symposium on Principles and Practice of Parallel Programming, PPoPP '16, pages 11:1&ndash;11:12, March 2016. Distinguished Paper. [[DOI](http://dx.doi.org/10.1145/2851141.2851145) | [http](http://escholarship.org/uc/item/6xz7z9k0)]

Yuduo Wu, Yangzihao Wang, Yuechao Pan, Carl Yang, and John D. Owens.
**Performance Characterization for High-Level Programming Models for GPU Graph
Analytics**. In IEEE International Symposium on Workload Characterization,
IISWC2015, October 2015. [[DOI](http://dx.doi.org/10.1109/IISWC.2015.13) | [http](http://web.ece.ucdavis.edu/~wyd855/iiswc-submission-2015.pdf)]

Carl Yang, Yangzihao Wang, and John D. Owens.
**Fast Sparse Matrix and Sparse Vector Multiplication Algorithm on the GPU**.
In Graph Algorithms Building Blocks, GABB 2015, May 2015.
[[DOI](http://dx.doi.org/10.1109/IPDPSW.2015.77) | [http](http://www.escholarship.org/uc/item/1rq9t3j3)]

Afton Geil, Yangzihao Wang, and John D. Owens.
**WTF, GPU! Computing Twitter's Who-To-Follow on the GPU**.
In Proceedings of the Second ACM Conference on Online Social Networks,
COSN '14, pages 63–68, October 2014.
[[DOI](http://dx.doi.org/10.1145/2660460.2660481) | [http](http://escholarship.org/uc/item/5xq3q8k0)]

Presentations

GTC 2016, Gunrock: A Fast and Programmable Multi-GPU Graph Processing Library, April 2016. [[slides](http://on-demand.gputechconf.com/gtc/2016/presentation/s6374-yangzihao-wang-gunrock.pdf)]

NVIDIA [webinar](http://info.nvidianews.com/gunrock-webinar-reg-0416.html), April 2016. [[slides](tinyurl.com/owens-nv-webinar-160426)]

GPU Technology Theater at SC15, Gunrock: A Fast and Programmable Multi-GPU Graph processing Library, November 2015. [[slides](http://images.nvidia.com/events/sc15/pdfs/SC5139-gunrock-multi-gpu-processing-library.pdf) | [video](http://images.nvidia.com/events/sc15/SC5139-gunrock-multi-gpu-processing-library.html)]

GTC 2014, High-Performance Graph Primitives on the GPU: design and Implementation of Gunrock, March 2014. [[slides](http://on-demand.gputechconf.com/gtc/2014/presentations/S4609-hi-perf-graph-primitives-on-gpus.pdf) | [video](http://on-demand.gputechconf.com/gtc/2014/video/S4609-hi-perf-graph-primitives-on-gpus.mp4)]

Gunrock Developers
------------------

- [Yangzihao Wang](http://www.idav.ucdavis.edu/~yzhwang/),
  University of California, Davis

- [Yuechao Pan](https://sites.google.com/site/panyuechao/home), University of California, Davis

- [Yuduo Wu](http://www.yuduowu.com/),
  University of California, Davis

- [Carl Yang](http://web.ece.ucdavis.edu/~ctcyang/),
  University of California, Davis
  
- [Leyuan Wang](http://www.ece.ucdavis.edu/~laurawly/),
  University of California, Davis
  
- Weitang Liu, University of California, Davis

- [Muhammad Osama](http://www.ece.ucdavis.edu/~mosama/),
  University of California, Davis

- Chenshan Shari Yuan, University of California, Davis

- Andy Riffel, University of California, Davis

- [Huan Zhang](http://www.huan-zhang.com/),
  University of California, Davis

- [John Owens](http://www.ece.ucdavis.edu/~jowens/),
  University of California, Davis

Acknowledgements
----------------

Thanks to the following developers who contributed code: The
connected-component implementation was derived from code written by
Jyothish Soman, Kothapalli Kishore, and P. J. Narayanan and described
in their IPDPSW '10 paper *A Fast GPU Algorithm for Graph
Connectivity* ([DOI](http://dx.doi.org/10.1109/IPDPSW.2010.5470817)).
The breadth-first search implementation and many of the utility
functions in Gunrock are derived from the
[b40c](http://code.google.com/p/back40computing/) library of
[Duane Merrill](https://sites.google.com/site/duanemerrill/). The
algorithm is described in his PPoPP '12 paper *Scalable GPU Graph
Traversal* ([DOI](http://dx.doi.org/10.1145/2370036.2145832)). Thanks
to Erich Elsen and Vishal Vaidyanathan from
[Royal Caliber](http://www.royal-caliber.com/) and the [Onu](http://www.onu.io/) Team for their discussion on
library development and the dataset auto-generating code. Thanks to
Adam McLaughlin for his technical discussion. Thanks to Oded Green
on his technical discussion and an optimization in CC primitive.

This work was funded by the DARPA XDATA program under AFRL Contract
FA8750-13-C-0002, by NSF awards CCF-1017399 and OCI-1032859, and by
DARPA STTR award D14PC00023. Our
XDATA principal investigator is Eric Whyne of
[Data Tactics Corporation](http://www.data-tactics.com/) and our DARPA
program managers are Dr. Christopher White (2012--2014) and [Mr. Wade
Shen](http://www.darpa.mil/staff/mr-wade-shen) (2015--now).

Copyright and Software License
----------------------------

Gunrock is copyright The Regents of the University of
California, 2015. The library, examples, and all source code are
released under
[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0).

