// ----------------------------------------------------------------
// Gunrock -- Fast and Efficient GPU Graph Library
// ----------------------------------------------------------------
// This source code is distributed under the terms of LICENSE.TXT
// in the root directory of this source distribution.
// ----------------------------------------------------------------

/**
 * @file
 * sm_problem.cuh
 *
 * @brief GPU Storage management Structure for SM Problem Data
 */

#pragma once

#include <gunrock/app/problem_base.cuh>
#include <gunrock/app/sm/sm_test.cuh>
#include <vector>
#include <string>
#include <algorithm>

namespace gunrock {
namespace app {
namespace sm {

/**
 * @brief Speciflying parameters for SM Problem
 * @param  parameters  The util::Parameter<...> structure holding all parameter
 * info \return cudaError_t error message(s), if any
 */
cudaError_t UseParameters_problem(util::Parameters &parameters) {
  cudaError_t retval = cudaSuccess;

  GUARD_CU(gunrock::app::UseParameters_problem(parameters));

  return retval;
}

/**
 * @brief Subgraph Matching Problem structure.
 * @tparam _GraphT  Type of the graph
 * @tparam _LabelT  Type of labels used in sm
 * @tparam _ValueT  Type of per-vertex distance values
 * @tparam _FLAG    Problem flags
 */
template <typename _GraphT, typename _LabelT = typename _GraphT::VertexT,
          typename _ValueT = typename _GraphT::ValueT,
          ProblemFlag _FLAG = Problem_None>
struct Problem : ProblemBase<_GraphT, _FLAG> {
  typedef _GraphT GraphT;
  static const ProblemFlag FLAG = _FLAG;
  typedef typename GraphT::VertexT VertexT;
  typedef typename GraphT::SizeT SizeT;
  typedef typename GraphT::CsrT CsrT;
  typedef typename GraphT::GpT GpT;
  typedef _LabelT LabelT;
  typedef _ValueT ValueT;

  typedef ProblemBase<GraphT, FLAG> BaseProblem;
  typedef DataSliceBase<GraphT, FLAG> BaseDataSlice;

  // Helper structures

  /**
   * @brief Data structure containing SM-specific data on indivual GPU.
   */
  struct DataSlice : BaseDataSlice {
    // sm-specific storage arrays
    util::Array1D<SizeT, VertexT> subgraphs;     // number of subgraphs
    util::Array1D<SizeT, VertexT> query_labels;  // query graph labels
    util::Array1D<SizeT, VertexT> data_labels;   // data graph labels

    util::Array1D<SizeT, SizeT> query_ro;     // query graph row offsets
    util::Array1D<SizeT, VertexT> query_ci;   // query graph column indices
    util::Array1D<SizeT, SizeT> data_degree;  // data graph nodes' degrees
    util::Array1D<SizeT, bool> isValid;   /** < Used for data node validation */
    util::Array1D<SizeT, bool> write_to;   /** < Used for store write info */
    util::Array1D<SizeT, SizeT> counter;  /** < Used for iteration recording */
    util::Array1D<SizeT, SizeT> value;    /** < Used for position recording */
    //util::Array1D<SizeT, SizeT> results;  /** < Used for gpu results   */
    util::Array1D<SizeT, SizeT>
        constrain;                    /** < Smallest degree in query graph   */
    util::Array1D<SizeT, VertexT> NS; /** < Used for query node explore seq  */
    util::Array1D<SizeT, int>
        NN; /** < Used for NS's tree neighbor based on previously visited NS*/
    util::Array1D<SizeT, int>
        NT; /** < Used for query node non-tree edge node info */
    util::Array1D<SizeT, SizeT>
        NT_offset; /** < Used for query node non-tree edge node offset info, one
                      node could have multiple non-tree edges */
                   //    util::Array1D<SizeT, VertexT>
                   //        partial; /** < Used for storing partial results */
    util::Array1D<SizeT, bool>
        flags_read; /** < Used for storing compacted src nodes */
    util::Array1D<SizeT, bool>
        flags_write; /** < Used for storing compacted src nodes */
    //util::Array1D<SizeT, VertexT>
    //    indices;       /** < Used for storing intermediate flag val */
    SizeT nodes_query; /** < Used for number of query nodes */
    SizeT num_matches; /** < Used for number of matches in the result */

    // query graph col_indices
    /*
     * @brief Default constructor
     */
    DataSlice() : BaseDataSlice() {
      subgraphs.SetName("subgraphs");
      query_labels.SetName("query_labels");
      data_labels.SetName("data_labels");
      query_ro.SetName("query_ro");
      data_degree.SetName("data_degree");
      isValid.SetName("isValid");
      write_to.SetName("write_to");
      counter.SetName("counter");
      value.SetName("value");
      //.SetName("results");
      constrain.SetName("constrain");
      NS.SetName("NS");
      NN.SetName("NN");
      NT.SetName("NT");
      NT_offset.SetName("NT_offset");
      //      partial.SetName("partial");
      flags_read.SetName("flags_read");
      flags_write.SetName("flags_write");
      //indices.SetName("indices");
      nodes_query = 0;
      num_matches = 0;
    }

    /*
     * @brief Default destructor
     */
    virtual ~DataSlice() { Release(); }

    /*
     * @brief Releasing allocated memory space
     * @param[in] target      The location to release memory from
     * \return    cudaError_t Error message(s), if any
     */
    cudaError_t Release(util::Location target = util::LOCATION_ALL) {
      cudaError_t retval = cudaSuccess;
      if (target & util::DEVICE) GUARD_CU(util::SetDevice(this->gpu_idx));

      GUARD_CU(subgraphs.Release(target));
      GUARD_CU(query_labels.Release(target));
      GUARD_CU(data_labels.Release(target));
      GUARD_CU(data_degree.Release(target));
      GUARD_CU(isValid.Release(target));
      GUARD_CU(write_to.Release(target));
      GUARD_CU(counter.Release(target));
      GUARD_CU(value.Release(target));
      //GUARD_CU(results.Release(target));
      GUARD_CU(constrain.Release(target));
      GUARD_CU(NS.Release(target));
      GUARD_CU(NN.Release(target));
      GUARD_CU(NT.Release(target));
      GUARD_CU(NT_offset.Release(target));
      //      GUARD_CU(partial.Release(target));
      GUARD_CU(flags_read.Release(target));
      GUARD_CU(flags_write.Release(target));
      //GUARD_CU(indices.Release(target));
      GUARD_CU(BaseDataSlice ::Release(target));
      return retval;
    }

    /**
     * @brief initializing sm-specific data on each gpu
     * @param     sub_graph   Sub graph on the GPU.
     * @param[in] num_gpus    Number of GPUs
     * @param[in] gpu_idx     GPU device index
     * @param[in] target      Targeting device location
     * @param[in] flag        Problem flag containling options
     * \return    cudaError_t Error message(s), if any
     */
    cudaError_t Init(GraphT &sub_graph, GraphT &query_graph, int num_gpus = 1,
                     int gpu_idx = 0, util::Location target = util::DEVICE,
                     ProblemFlag flag = Problem_None) {
      cudaError_t retval = cudaSuccess;
      int num_query_edge = query_graph.edges / 2;
      int num_query_node = query_graph.nodes;

      printf("subgraph nodes: %d, query graph nodes:%d\n", sub_graph.nodes,
             query_graph.nodes);
      GUARD_CU(BaseDataSlice::Init(sub_graph, num_gpus, gpu_idx, target, flag));
      GUARD_CU(subgraphs.Allocate(sub_graph.nodes, target));
      GUARD_CU(
          query_ro.Allocate(num_query_node + 1, util::HOST | util::DEVICE));
      GUARD_CU(data_degree.Allocate(sub_graph.nodes, util::DEVICE));
      GUARD_CU(isValid.Allocate(sub_graph.nodes, util::DEVICE));
      GUARD_CU(write_to.Allocate(sub_graph.nodes, util::DEVICE));
      GUARD_CU(counter.Allocate(1, util::HOST | util::DEVICE));
      GUARD_CU(value.Allocate(1, util::HOST | util::DEVICE));
      //GUARD_CU(results.Allocate(sub_graph.nodes * sub_graph.edges, util::HOST | util::DEVICE));
      GUARD_CU(constrain.Allocate(1, util::HOST | util::DEVICE));
      GUARD_CU(NS.Allocate(2 * num_query_node, util::HOST | util::DEVICE));
      GUARD_CU(NN.Allocate(num_query_node, util::HOST | util::DEVICE));
      GUARD_CU(NT.Allocate(num_query_edge, util::HOST | util::DEVICE));
      GUARD_CU(
          NT_offset.Allocate(num_query_node + 1, util::HOST | util::DEVICE));
      // partial results storage: as much as possible
      //      GUARD_CU(partial.Allocate(sub_graph.edges ^ (num_query_node - 1),
      //                                util::DEVICE));
      GUARD_CU(flags_read.Allocate(pow(sub_graph.nodes, num_query_node), util::DEVICE));
      GUARD_CU(flags_write.Allocate(pow(sub_graph.nodes, num_query_node), util::DEVICE));
      //GUARD_CU(indices.Allocate(pow(sub_graph.nodes, num_query_node), util::DEVICE));

      // Initialize query graph node degree by row offsets
      // neighbor node encoding = sum of neighbor node labels

      int *query_degree = new int[num_query_node];
      for (int i = 0; i < num_query_node; i++) {
        query_degree[i] =
            query_graph.row_offsets[i + 1] - query_graph.row_offsets[i];
      }
      // Generate query graph node exploration sequence based on maximum
      // likelihood estimation (MLE) node mapping degree, TODO:probablity
      // estimation based on label and degree
      int *d_m = new int[num_query_node];
      memset(d_m, 0, sizeof(int) * num_query_node);
      int degree_max = query_degree[0];
      int degree_min = query_degree[0];
      int index = 0;
      for (int i = 0; i < num_query_node; ++i) {
        if (i == 0) {
          // find maximum degree in query graph and corresponding node index
          for (int j = 1; j < num_query_node; ++j) {
            if (query_degree[j] > degree_max) {
              index = j;
              degree_max = query_degree[j];
            } else {
              degree_min = query_degree[j];
            }
          }
        } else {
          int dm_max = 0;
          index = 0;
          while (d_m[index] == -1) {
            index++;
          }
          for (int j = 0; j < num_query_node; ++j) {
            if (d_m[j] >= 0) {
              if (index * degree_max + query_degree[j] > dm_max) {
                dm_max = index * degree_max + query_degree[j];
                index = j;
              }
            }
          }
        }
        // put the node index with max degree in NS, and mark that node as
        // solved -1, and add priority to its neighbors
        NS[i] = index;
        d_m[index] = -1;
        for (int j = query_graph.row_offsets[index];
             j < query_graph.row_offsets[index + 1]; ++j)
          if (d_m[query_graph.column_indices[j]] != -1)
            d_m[query_graph.column_indices[j]]++;
      }
      constrain[0] = degree_min;
      delete[] d_m;
      delete[] query_degree;

      int count = 0;
      for (int i = 0; i < num_query_node; ++i) {
        NT[i] = -1;
        NN[i] = -1;
      }
      NT_offset[0] = 0;
      for (int i = 0; i < num_query_node; ++i) {
        if (i == 0)
          NT_offset[i + 1] = 0;
        else
          NT_offset[i + 1] = NT_offset[i];
        // for each neighbor of i, traveres previously visited NS, see if any is
        // its neighbor
        for (int j = 0; j < i; ++j) {
          for (int n = query_graph.row_offsets[NS[i]];
               n < query_graph.row_offsets[NS[i] + 1]; ++n) {
            if (query_graph.column_indices[n] == NS[j]) {
              // we assume the first neigboring NS a tree-neighbor
              if (NN[i] == -1) NN[i] = j;  // which pos of node in NS => NS[j]
              // others non-tree neighbors
              else {
                NT[count++] = j;  // which pos of the node n NS => NS[j]
                NT_offset[i + 1]++;
              }
            }
          }
        }
      }

      // Add 1 look ahead info: each query node's neighbors' min degree in the
      // pos of (index + num_query_node, min_degree) where index is the sequence
      // id of each query node in NS
      for (int i = 0; i < query_graph.nodes; ++i) {
        VertexT src = NS[i];
        int min_degree = INT_MAX;
        for (int j = query_graph.row_offsets[src];
             j < query_graph.row_offsets[src + 1]; ++j) {
          VertexT dest = query_graph.column_indices[j];
          if (query_graph.row_offsets[dest + 1] -
                  query_graph.row_offsets[dest] <
              min_degree) {
            min_degree = query_graph.row_offsets[dest + 1] -
                         query_graph.row_offsets[dest];
          }
        }
        NS[i + num_query_node] = min_degree;
      }

      GUARD_CU(NS.Move(util::HOST, target));
      GUARD_CU(NN.Move(util::HOST, target));
      GUARD_CU(NT.Move(util::HOST, target));
      GUARD_CU(NT_offset.Move(util::HOST, target));
      GUARD_CU(constrain.Move(util::HOST, target));
      // Initialize query row offsets with query_graph.row_offsets
      GUARD_CU(query_ro.ForAll(
          [query_graph] __host__ __device__(SizeT * x, const SizeT &pos) {
            x[pos] = query_graph.row_offsets[pos];
          },
          num_query_node + 1, util::HOST));
      GUARD_CU(query_ro.Move(util::HOST, target));
      GUARD_CU(isValid.ForAll(
          [] __device__(bool *x, const SizeT &pos) { x[pos] = true; },
          sub_graph.nodes, target, this->stream));
      GUARD_CU(write_to.ForAll(
          [] __device__(bool *x, const SizeT &pos) { x[pos] = false; },
          sub_graph.nodes, target, this->stream));
      GUARD_CU(flags_read.ForAll(
          [] __device__(bool * x, const SizeT &pos) { x[pos] = false; },
          pow(sub_graph.nodes, num_query_node), target, this->stream));
      GUARD_CU(flags_write.ForAll(
          [] __device__(bool * x, const SizeT &pos) { x[pos] = false; },
          pow(sub_graph.nodes, num_query_node), target, this->stream));
      /*GUARD_CU(indices.ForAll(
          [] __device__(VertexT * x, const SizeT &pos) { x[pos] = pos; },
          pow(sub_graph.nodes, num_query_node), target, this->stream));*/
      GUARD_CU(data_degree.ForAll(
          [] __device__(SizeT * x, const SizeT &pos) { x[pos] = 0; },
          sub_graph.nodes, target, this->stream));
      GUARD_CU(counter.ForAll(
          [] __device__(SizeT * x, const SizeT &pos) { x[pos] = 0; }, 1, target,
          this->stream));
      /*GUARD_CU(results.ForAll(
          [] __host__ __device__(SizeT * x, const SizeT &pos) { x[pos] = 0; },
          sub_graph.nodes * sub_graph.edges, target, this->stream));*/

      nodes_query = query_graph.nodes;

      if (target & util::DEVICE) {
        GUARD_CU(sub_graph.CsrT::Move(util::HOST, target, this->stream));
        return retval;
      }

      return retval;
    }  // Init

    /**
     * @brief Reset problem function. Must be called prior to each run.
     * @param[in] target      Targeting device location
     * \return    cudaError_t Error message(s), if any
     */
    cudaError_t Reset(util::Location target = util::DEVICE) {
      cudaError_t retval = cudaSuccess;
      SizeT num_nodes = this->sub_graph->nodes;
      SizeT num_edges = this->sub_graph->edges;

      // Ensure data are allocated
      GUARD_CU(subgraphs.EnsureSize_(num_nodes, target));
      //            GUARD_CU(nodes     .EnsureSize_(num_nodes, target));

      // Reset data
      GUARD_CU(subgraphs.ForEach(
          [] __host__ __device__(VertexT & x) { x = (VertexT)0; }, num_nodes,
          target, this->stream));

      return retval;
    }
  };  // DataSlice

  // Members
  // Set of data slices (one for each GPU)
  util::Array1D<SizeT, DataSlice> *data_slices;

  // Methods

  /**
   * @brief SMProblem default constructor
   */
  Problem(util::Parameters &_parameters, ProblemFlag _flag = Problem_None)
      : BaseProblem(_parameters, _flag), data_slices(NULL) {}

  /**
   * @brief SMProblem default destructor
   */
  virtual ~Problem() { Release(); }

  /*
   * @brief Releasing allocated memory space
   * @param[in] target      The location to release memory from
   * \return    cudaError_t Error message(s), if any
   */
  cudaError_t Release(util::Location target = util::LOCATION_ALL) {
    cudaError_t retval = cudaSuccess;
    if (data_slices == NULL) return retval;
    for (int i = 0; i < this->num_gpus; i++)
      GUARD_CU(data_slices[i].Release(target));

    if ((target & util::HOST) != 0 &&
        data_slices[0].GetPointer(util::DEVICE) == NULL) {
      delete[] data_slices;
      data_slices = NULL;
    }
    GUARD_CU(BaseProblem::Release(target));
    return retval;
  }

  /**
   * \addtogroup PublicInterface
   * @{
   */

  /**
   * @brief Copy result distancess computed on GPUs back to host-side arrays.
   * @param[out] h_distances Host array to store computed vertex distances from
   * the source.
   * @param[out] h_preds     Host array to store computed vertex predecessors.
   * @param[in]  target where the results are stored
   * \return     cudaError_t Error message(s), if any
   */
  cudaError_t Extract(VertexT *h_subgraphs,
                      util::Location target = util::DEVICE) {
    cudaError_t retval = cudaSuccess;
    SizeT nodes = this->org_graph->nodes;

    if (this->num_gpus == 1) {
      auto &data_slice = data_slices[0][0];
      SizeT nodes_query = data_slice.nodes_query;
      bool *h_results = new bool[pow(nodes, nodes_query)];

      // Set device
      if (target == util::DEVICE) {
        GUARD_CU(util::SetDevice(this->gpu_idx[0]));

        GUARD_CU(data_slice.flags_write.SetPointer(h_results, pow(nodes, nodes_query), util::HOST));
        GUARD_CU(data_slice.flags_write.Move(util::DEVICE, util::HOST));
      } else if (target == util::HOST) {
        GUARD_CU(data_slice.flags_write.ForEach(
            h_results,
            [] __host__ __device__(const VertexT &d_x, VertexT &h_x) {
              h_x = d_x;
            }, pow(nodes, nodes_query), util::HOST));
      }
    } else {  // num_gpus != 1

      // !! MultiGPU not implemented

      // util::Array1D<SizeT, ValueT *> th_subgraphs;
      // util::Array1D<SizeT, VertexT*> th_nodes;
      // th_subgraphs.SetName("bfs::Problem::Extract::th_subgraphs");
      // th_nodes     .SetName("bfs::Problem::Extract::th_nodes");
      // GUARD_CU(th_subgraphs.Allocate(this->num_gpus, util::HOST));
      // GUARD_CU(th_nodes    .Allocate(this->num_gpus, util::HOST));

      // for (int gpu = 0; gpu < this->num_gpus; gpu++)
      // {
      //     auto &data_slice = data_slices[gpu][0];
      //     if (target == util::DEVICE)
      //     {
      //         GUARD_CU(util::SetDevice(this->gpu_idx[gpu]));
      //         GUARD_CU(data_slice.subgraphs.Move(util::DEVICE, util::HOST));
      //         GUARD_CU(data_slice.nodes.Move(util::DEVICE, util::HOST));
      //     }
      //     th_subgraphs[gpu] = data_slice.subgraphs.GetPointer(util::HOST);
      //     th_nodes    [gpu] = data_slice.nodes    .GetPointer(util::HOST);
      // } //end for(gpu)

      // for (VertexT v = 0; v < nodes; v++)
      // {
      //     int gpu = this -> org_graph -> GpT::partition_table[v];
      //     VertexT v_ = v;
      //     if ((GraphT::FLAG & gunrock::partitioner::Keep_Node_Num) != 0)
      //         v_ = this -> org_graph -> GpT::convertion_table[v];

      //     h_subgraphs[v] = th_subgraphs[gpu][v_];
      //     h_node      [v] = th_nodes     [gpu][v_];
      // }

      // GUARD_CU(th_subgraphs.Release());
      // GUARD_CU(th_nodes     .Release());
    }  // end if
    // further extract combination from h_results to h_subgraphs
    vector<vector<int>> combinations;
    for (int i = 0; i < pow(nodes, nodes_query); ++i) {
      if (h_results[i]) {
        int key = i;
        int stride = pow(nodes, nodes_query);
        vector<int> combination;
        for (int j = 0; j < nodes_query; ++j) {
          stride = stride / nodes;
          int elem = key / stride;
          combination.push_back(elem);
          key = key - elem * stride;
        }
        std::sort (combination.begin(), combination.end());
        combinations.push_back(combination);
      }
    }
    vector<vector<int> >::iterator itr = unique(combinations.begin(), combinations.end());
    combinations.resize(combinations.begin(), itr);
    h_subgraphs[0] = combinations.size();
    //TODO: export combinations to output
    return retval;
  }

  /**
   * @brief initialization function.
   * @param     graph       The graph that SM processes on
   * @param[in] Location    Memory location to work on
   * \return    cudaError_t Error message(s), if any
   */
  cudaError_t Init(GraphT &graph, GraphT &query_graph,
                   util::Location target = util::DEVICE) {
    cudaError_t retval = cudaSuccess;
    GUARD_CU(BaseProblem::Init(graph, target));
    data_slices = new util::Array1D<SizeT, DataSlice>[this->num_gpus];

    for (int gpu = 0; gpu < this->num_gpus; gpu++) {
      data_slices[gpu].SetName("data_slices[" + std::to_string(gpu) + "]");
      if (target & util::DEVICE) GUARD_CU(util::SetDevice(this->gpu_idx[gpu]));

      GUARD_CU(data_slices[gpu].Allocate(1, target | util::HOST));

      auto &data_slice = data_slices[gpu][0];
      GUARD_CU(data_slice.Init(this->sub_graphs[gpu], query_graph,
                               this->num_gpus, this->gpu_idx[gpu], target,
                               this->flag));
    }  // end for (gpu)

    return retval;
  }

  /**
   * @brief Reset problem function. Must be called prior to each run.
   * @param[in] src      Source vertex to start.
   * @param[in] location Memory location to work on
   * \return cudaError_t Error message(s), if any
   */
  cudaError_t Reset(util::Location target = util::DEVICE) {
    cudaError_t retval = cudaSuccess;

    for (int gpu = 0; gpu < this->num_gpus; ++gpu) {
      // Set device
      if (target & util::DEVICE) GUARD_CU(util::SetDevice(this->gpu_idx[gpu]));
      GUARD_CU(data_slices[gpu]->Reset(target));
      GUARD_CU(data_slices[gpu].Move(util::HOST, target));
    }

    GUARD_CU2(cudaDeviceSynchronize(), "cudaDeviceSynchronize failed");
    return retval;
  }

  /** @} */
};

}  // namespace sm
}  // namespace app
}  // namespace gunrock

// Leave this at the end of the file
// Local Variables:
// mode:c++
// c-file-style: "NVIDIA"
// End:
