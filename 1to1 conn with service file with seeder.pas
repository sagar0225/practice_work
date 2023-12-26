
---------------------(Migration)-----------------
 1)tasks
 
 public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
           
            $table->bigIncrements('id');
            $table->string('name');
            $table->timestamps();
        });
    }



2)workers

 public function up(): void
    {
        Schema::create('workrs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name');
            $table->string('email')->unique();
            $table->string('mobile')->unique();
            $table->unsignedBigInteger('task_id');
            $table->foreign('task_id')->references('id')->on('tasks')->onDelete('cascade');
            $table->string('password', 10);
            $table->timestamps();
        });
    }
	
	
	
	
	
	
	
	-------------------------(Model)------------------------------
	
	1)workers
	
	class Worker extends Model
{
    use HasFactory;
    protected $table = 'workrs';
    protected $fillable = ['name','email','mobile ','task_id','password'];
    
    public function task()
    {
        return $this->belongsTo(Task::class);
    }
}

	2)Task
	
	class Task extends Model
{
    use HasFactory;
    
    public function worker()
    {
        return $this->hasOne(Worker::class);
    }
}




------------------(Seeder)----------------------------

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;



 public function run(): void
    {
        // Insert data into the table
        DB::table('tasks')->insert([
            'id' => 1,
            'name' => 'create data',
            'created_at' => Carbon::now(),
        ]);
        DB::table('tasks')->insert([
            'id' => 2,
            'name' => 'delete data',
            'created_at' => Carbon::now(),
        ]);
        DB::table('tasks')->insert([
            'id' => 3,
            'name' => 'read data',
            'created_at' => Carbon::now(),
        ]);
        DB::table('tasks')->insert([
            'id' => 4,
            'name' => 'update data',
            'created_at' => Carbon::now(),
        ]);
        DB::table('tasks')->insert([
            'id' => 5,
            'name' => 'testing data',
            'created_at' => Carbon::now(),
        ]);
    }
	
	
	
	
------------------(Service)-----------------------------------------------
	
	*WorkerService
	
	
namespace App\Services;
use Exception;
use App\Models\Task;
use App\Models\Worker;
use App\Http\Controllers\workrController;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Console\Input\Input;

	
	
	class WorkerService

{
	public $worker;

	public function __construct()
	{
		$this-> worker = new Worker();
		
	}
    public function saveW($input)
	{
		try {
				$workerObj = new Worker();
				$workerObj->name = $input['name'];
                $workerObj->email =  $input['email'];
                $workerObj->mobile =  $input['mobile'];
				$workerObj->task_id = $input['task_id']; 
                $workerObj->password =  $input['password']; 
				$response = $workerObj->save();
                //dd($response);
	if ($response) {
				return [
					'status' => true,
					'message' => 'workers added successfully',
					'data' => $response,
				];
			} else {
				return [
					'status' => false,
					'message' => 'Unable to added worker record',
					'data' => null,
				];
			}
		}catch(Exception $e) {
			return [
				'status' => false,
				'message' => $e->getMessage(),
				'data' => null,
			];
		}
    }
     
    public function workerRecord($id)
    {
    	  $record =Worker::with('task')->find($id);   -->(for getting both table data)
    	  return $record;
    }

}

----------------------(Controller)--------------------------------------


*WorkerController

use App\Services\WorkerService;
use Illuminate\Http\Request;
use App\Models\Worker;


class workerController extends Controller
{
   
    public $WorkerService;
    public function __construct()
    {
        $this->WorkerService = new WorkerService();
    }
    public function store(Request $request)
    {
        try {
            $validateUser = Worker::make(
                $request->all(),
                [
                    'name'=> 'required',
                    'email'=>'requird',
                    'mobile'=>'requird',
                    'task_id'=>'required',
                    'password' => 'required',
                ]
            );
            if (!$validateUser) {
                return response()->json([
                    'status' => false,
                    'message' => 'validation error',
                    'errors' => $validateUser->errors()
                ], 401);
            }
            $input = $request->all();
            //dd( $input);
            $workerService = Worker::where('email', $input['email'])->first();
           //dd( $workrService);
            if ($workerService) {
                return response()->json([
                    'status' => false,
                    'message' => 'Email  is already exists',
                ], 400);
            }
                //dd($input);
                $result = $this->WorkerService->saveW($input);
          // dd($result);
            if ($result['status']) {
                return response()->json([
                    'status' => true,
                    'message' => $result['message'],
                ], 200);
            } else {
                return response()->json([
                    'status' => false,
                    'message' => $result['message'],
                ], 500);
            }
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
    
    public function edit($id)
    {
        $workers = $this->WorkerService->workerRecord($id); //data show by id
       // dd( $Emp);
        if ( $workers) {
            return response()->json([
                'status' => true,
                'message' => 'Find record',
                'response' =>$workers,
            ],200);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'Record not found',
                'response' =>$workers,
            ],404);
        }
    }
    public function index()
    {
        // Retrieve all workers with their associated tasks
        $workers = Worker::with('task')->get();  
        return [
            'status' => true,
            'message' => 'workers show successfully',
            'data' => $workers,
        ];
        
    }
}

--------------------(Route)-----------------------------


Route::post('addworker',[workerController::class,'store']);
Route::get('/workers', [workerController::class, 'index']);
Route::get('emp/{id}',[workerController::class,'edit']);