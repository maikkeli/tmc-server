# frozen_string_literal: true

module ExercisesHelper
  def exercise_zip_url(e)
    exercise_url(e, format: 'zip').to_s
  end

  def exercise_solution_zip_url(e)
    exercise_solution_url(e, format: 'zip').to_s
  end

  def green(percentage)
    percentage || 0
  end

  def red(percentage_of_green)
    100 - (percentage_of_green || 100)
  end
end
