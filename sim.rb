class Request
  attr_accessor :tik, :tok

  def initialize(tik)
    if tik == 10 then
      @tik = rand(1..1000)
    else
      @tik = tik
    end
    @tok = 0
  end

  def process
    @tik -= 1
    @tok += 1
  end

  def finished?
    @tik == 0
  end

  def time
    @tok
  end
end

class Worker
  attr_accessor :request

  def initialize
    @request = nil
  end

  def new_request(request)
    return false unless available?
    @request = request
  end

  def process_request
    @request.process unless @request.finished?
    Results.tally_request(@request) if @request.finished?
  end

  def available?
    return true if @request.nil?
    @request.finished?
  end
end

class Queue
  attr_accessor :workers, :requests

  def initialize
    @workers = []
    @requests = []
  end

  def set_workers(num_workers)
    num_workers.times { @workers << Worker.new }
  end

  def add_requests(requests_array)
    requests_array.each { |request| @requests << request }
  end

  def submit_to_workers
    @workers.each do |worker|
      worker.new_request(@requests.pop) if worker.available?
    end
  end

  def run_workers
    @workers.each {|worker| worker.process_request}
  end

end

ALL_REQ_DIST = {1 => 0.8909147854,2 => 0.0446235047,3 => 0.0090257783,4 => 0.0063991914,5 => 0.0081288949,6 => 0.0057621195,7 => 0.0092072904,8 => 0.0094243931,9 => 0.0059614269}
TIK_REQ_DIST = {1 => 0.3296444549,2 => 0.3018601366,3 => 0.2116788321,4 => 0.0713444785,5 => 0.0397927949,6 => 0.0228396515,7 => 0.0082411114,8 => 0.0056510478,9 => 0.0018836826}
PRO_REQ_DIST_2k = {1 => 0.8526524592,2 => 0.0621595678,3 => 0.0228408275,4 => 0.0108265727,5 => 0.0102874528,6 => 0.0069263109,7 => 0.009141425,8 => 0.0091671606,9 => 0.0056834432}
PRO_REQ_DIST_4k = {1 => 0.8192094017,2 => 0.0774869048,3 => 0.0349158248,4 => 0.0146963104,5 => 0.012174133,6 => 0.0079438685,7 => 0.0090838557,8 => 0.0089423274,9 => 0.0054404725}

class Submitter
  attr_accessor :distribution, :requests, :count, :rate, :queue

  def initialize(count,rate,queue)
    @distribution = {}
    @count = count
    @requests = []
    @rate = rate
    @queue = queue
  end

  def set_distribution(distribution)
    @distribution = distribution
  end

  def generate_requests
    request_tally = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0}
    @distribution.each_pair {|k,v| request_tally[k] = (v * @count).floor }
    to_generate = request_tally.values.inject(0) {|sum,x| x + sum }
    to_generate.times {|x| request_tally[rand(1..10)] += 1}
    request_tally.each_pair {|k,v| v.times { @requests << Request.new(k) } }
    @requests.shuffle!
  end

  def submit
    @queue.add_requests(@requests.pop(@rate))
  end

end

class Results

  class << self

    def tally_request(request)
      puts request.time
    end

  end

end
