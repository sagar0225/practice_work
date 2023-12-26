---------------(Migration)------------------------------



public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email');
            $table->string('mobile');
            $table->timestamps();
        });
    }
	
---------------------(Model)-------------------------------------------

<?php

namespace App\Models;
use App\Exports\StudentsExport;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;
    protected $table ='students';
    protected $fillable = ['name','email','mobile '];
}

-----------------(StudentService)-----------------------------------

<?php 


namespace App\Services;
use Exception;
use App\Models\Student;
use App\Http\Controllers\StudentController;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Console\Input\Input;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Facades\Excel;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
	
	
	class StudentService

{
	public $student;

	public function __construct()
	{
		$this-> student = new Student();
		
	}

public function exportStudentsToCSV()
    {
        $students = Student::all();

        $csvHeader = ['id', 'name', 'email'];
        $csvData = [$csvHeader];

        foreach ($students as $student) {
            $csvData[] = [
                $student->id,
                $student->name,
                $student->email,
              
            ];
        }

        $csvContent = implode(PHP_EOL, array_map(function ($row) {
            return implode(',', $row);
        }, $csvData));

        $filePath = 'exports/students.csv';

        Storage::put($filePath, $csvContent);

        return $filePath;
    }

-----------------------(StudentController)--------------------------------


<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Student;
use App\Services\StudentService;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\TableDataExport;
use Maatwebsite\Excel\Concerns\FromCollection;


class StudentController extends Controller
{
    public $studentService;

	public function __construct()
	{
		$this-> studentService = new StudentService();
		
	}

public function exportStudents()
    {
        $filePath = $this->studentService->exportStudentsToCSV();

        return response()->download(storage_path("app/{$filePath}"))
            ->deleteFileAfterSend(true);
    }
	
	----------------------(Route)----------------------------------------------
	
	Route::get('export', [StudentController::class, 'exportStudents']);