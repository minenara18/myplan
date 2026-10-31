<?php

namespace App\Policies;

use App\Models\Course;
use App\Models\User;

final class CoursePolicy
{
    public function viewAny(User $user): bool
    {
        return true; // indeks selalu diekerling per user di controller
    }

    public function view(User $user, Course $course): bool
    {
        return $course->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Course $course): bool
    {
        return $course->user_id === $user->id;
    }

    public function delete(User $user, Course $course): bool
    {
        return $course->user_id === $user->id;
    }
}
